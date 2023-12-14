import { AccountWallet, AztecAddress, Fr, PXE, TxStatus, Wallet, computeMessageSecretHash, createAccount, createPXEClient, Contract } from "@aztec/aztec.js";
import { TokenContract } from "@aztec/noir-contracts/types";
import { PayslipContract } from "../contracts/target/Payslip.js"

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

    // const initialBalance = 20n;
    // const secret: Fr = Fr.random();
    // const secretHash = await computeMessageSecretHash(secret)
    // const mint_receipt = await token.methods.mint_private(initialBalance, secretHash).send().wait();
    //
    // const storageSlot = new Fr(5)


  }, 60000);

  it('Check Contract Deployment', async () => {
    expect(token.completeAddress).toBeDefined()
    expect(payslip.completeAddress).toBeDefined()
  })

  xit('Generate Receipt', async () => {
    //   // distribute token to sender
    //
  })

})
