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
} from "@aztec/aztec.js";
import { TokenContract } from "@aztec/noir-contracts/types";
import { PayslipContract } from "../contracts/target/Payslip.js"
// import { createSandbox } from "@aztec/aztec-sandbox"

const { PXE_URL = "http://localhost:8080" } = process.env

describe('receipt contract', () => {

  let pxe: PXE;
  let deployer: AccountWallet;
  let payer: AccountWallet;
  let payee: AccountWallet;
  let token: TokenContract;
  let payslip: PayslipContract;


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

  it('Distribute token to payer', async () => {
    //   // distribute token to sender
    //
    // distribute token
    const initialBalance = 20n;
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

})
