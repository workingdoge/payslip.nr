import { AccountWallet, AztecAddress, Fr, PXE, TxStatus, Wallet, Note, ExtendedNote, computeMessageSecretHash, createAccount, createPXEClient, Contract } from "@aztec/aztec.js";
import { TokenContract } from "@aztec/noir-contracts/types";
import { PayslipContract } from "../contracts/target/Payslip.js"
import { MinInt256 } from "ethers";

const { PXE_URL = "http://localhost:8080" } = process.env

describe('receipt contract', () => {

  let pxe: PXE;
  let deployer: AccountWallet;
  let sender: AccountWallet;
  let recipient: AccountWallet;
  let token: Contract;
  let payslip: Contract;


  beforeEach(async () => {

    // setup
    pxe = createPXEClient(PXE_URL);
    deployer = await createAccount(pxe);
    sender = await createAccount(pxe);
    recipient = await createAccount(pxe);

    token = await TokenContract.deploy(deployer, deployer.getCompleteAddress()).send().deployed()
    console.log("token deployed")
    console.log(token)

    payslip = await PayslipContract.deploy(deployer).send().deployed();
    console.log("payslip deployed")
    console.log(payslip)  

    const recipientAddress = recipient.getAddress();
    expect(await token.methods.balance_of_private(recipientAddress).view()).toEqual(0n);

    // mint tokens privately
    const mintAmount = 20n;
    const secret = Fr.random();
    const secretHash = computeMessageSecretHash(secret);
    const mint_receipt = await token.methods.mint_private(mintAmount, secretHash).send().wait();

    const storageSlot = new Fr(5); // The storage slot of `pending_shields` is 5.
    const note = new Note([new Fr(mintAmount), secretHash]);
    const extendedNote = new ExtendedNote(note, recipientAddress, token.address, storageSlot, mint_receipt.txHash);
    await pxe.addNote(extendedNote);

    await token.methods.redeem_shield(recipientAddress, mintAmount, secret).send().wait();
    expect(await token.methods.balance_of_private(recipientAddress).view()).toEqual(20n);


  }, 600000);

  it('Check Contract Deployment', async () => {
    expect(token.completeAddress).toBeDefined()
    expect(payslip.completeAddress).toBeDefined()
  })
  
  it('mint private tokens', async () => {
    const recipientAddress = recipient.getAddress();
    const senderAddress = sender.getAddress(); 
    expect(await token.methods.balance_of_private(senderAddress).view()).toEqual(0n);
    expect(await token.methods.balance_of_private(recipientAddress).view()).toEqual(20n);
  })

  xit('Generate Receipt', async () => {
    //  distribute token to sender
    const token_address = token.completeAddress; 
    // note: sender and receiver address flipped because funds are now with recipient after initial transfer. 
    const senderAddress = sender.getAddress(); 
    const recipientAddress = recipient.getAddress();
    //(token_address: Field, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field)
    const mint_payslip = await payslip.methods.transfer_with_payslip(token_address, recipientAddress, senderAddress,20n, 0).send().wait(); 
    expect(await token.methods.balance_of_private(senderAddress).view()).toEqual(20n);
    expect(await token.methods.balance_of_private(recipientAddress).view()).toEqual(0n);
  })

})
