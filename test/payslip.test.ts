import {
  AccountWallet,
  AztecAddress,
  ExtendedNote,
  Fr,
  PXE,
  TxStatus,
  computeMessageSecretHash,
  createAccount,
  createPXEClient,
  Contract,
  Note,
  computeAuthWitMessageHash,
} from "@aztec/aztec.js";
import { TokenContract } from "@aztec/noir-contracts/types";
import { PayslipContract } from "../contracts/payslip/target/Payslip.js"

const { PXE_URL = "http://localhost:8080" } = process.env

describe('receipt contract', () => {

  let pxe: PXE;
  let deployer: AccountWallet;
  let payer: AccountWallet;
  let payee: AccountWallet;
  let token: TokenContract;
  let payslip: PayslipContract;
  let initialBalance: bigint;

  beforeAll(async () => {
    // setup
    pxe = createPXEClient(PXE_URL);

    deployer = await createAccount(pxe)
    payer = await createAccount(pxe)
    payee = await createAccount(pxe)

    token = await TokenContract.deploy(deployer, deployer.getAddress()).send().deployed()

    console.log("token deployed")
    console.log(token)

    payslip = await PayslipContract.deploy(deployer).send().deployed();
    console.log("payslip deployed")
    console.log(payslip)
  }, 60000);

  it('Check Contract Deployment', async () => {
    expect(token.completeAddress).toBeDefined()
    expect(payslip.completeAddress).toBeDefined()
  })

  it('Mint and Distribute token to payer', async () => {
    //   // distribute token to sender
    //
    // distribute token
    initialBalance = 20n;
    const secret: Fr = Fr.random();

    // this is for sending l1 to l2 messages, possibility for l2 to l2 messages?
    const secretHash = computeMessageSecretHash(secret)
    const mint_receipt = await token.methods.mint_private(initialBalance, secretHash).send().wait();


    const storageSlot = new Fr(5); // The storage slot of `pending_shields` is 5.
    const note = new Note([new Fr(initialBalance), secretHash]);
    const extendedNote = new ExtendedNote(note, payer.getAddress(), token.address, storageSlot, mint_receipt.txHash);
    await pxe.addNote(extendedNote);

    await token.methods.redeem_shield(payer.getAddress(), initialBalance, secret).send().wait();

    expect(await token.methods.balance_of_private(payer.getAddress()).view()).toEqual(20n);

  }, 1000000)

  it('Transfer and Generate Receipt', async () => {

    //  distribute token to sender
    const nonce = Fr.random()
    const payerAddress = payer.getAddress()
    const payeeAddress = payee.getAddress()

    // generate authwit
    const transfer_and_mint_payslip =
      payslip.withWallet(payer).methods.transfer_and_mint_payslip(
        token.address,
        payerAddress,
        payeeAddress,
        initialBalance,
        nonce
      )

    const transfer = token.methods.transfer(payerAddress, payeeAddress, initialBalance, nonce)

    const authwit_message_hash = computeAuthWitMessageHash(payslip.address, transfer.request())
    console.log(authwit_message_hash)
    const witness = await payer.createAuthWitness(authwit_message_hash)
    await payer.addAuthWitness(witness)


    const payslip_receipt = await transfer_and_mint_payslip.send().wait()

    console.log("payer: ", await token.methods.balance_of_private(payerAddress).view())
    console.log("payee: ", await token.methods.balance_of_private(payeeAddress).view())


    // verify balances are correct
    expect(await token.methods.balance_of_private(payerAddress).view()).toEqual(0n);
    expect(await token.methods.balance_of_private(payeeAddress).view()).toEqual(20n);

    const storageSlot = new Fr(1); // The storage slot of `payslips` is 1.
    const payslipNote = new Note([payerAddress, payeeAddress, new Fr(initialBalance), nonce]);
    const extendedPayslipNote = new ExtendedNote(payslipNote, payer.getAddress(), token.address, storageSlot, payslip_receipt.txHash);
    await pxe.addNote(extendedPayslipNote);



    // TODO: payee (to) should be able to construct a proof that the transfer was sent from the payer (from)
    // TODO: Create function which links payment note to receipt note

    // TODO: Compute "safety_score": percentage of debits which have verified payers
    // Get all transfers to account, get all receipts to account (link?) and divide all receipts by all transfers



    // TODO: explore the encrypted log method and proofs with encrypted logs (decrypt)

  }, 100000)

})
