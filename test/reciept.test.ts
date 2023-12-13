import { AccountWallet, AztecAddress, Fr, PXE, TxStatus, Wallet, computeMessageSecretHash, createAccount, createPXEClient, Contract } from "@aztec/aztec.js";
import { TokenContract } from "@aztec/noir-contracts";
import { ReceiptCreatorContract, ReceiptCreatorContractArtifact } from "../contracts/artifacts/ReceiptCreator"

const { PXE_URL = "http://localhost:8080" } = process.env

describe('receipt contract', () => {

  let pxe: PXE;
  let deployer: AccountWallet;
  let sender: AccountWallet;
  let recipient: AccountWallet;
  let token: Contract;
  let receipt_creator: Contract;


  beforeEach(async () => {

    // setup
    pxe = createPXEClient(PXE_URL);
    deployer = await createAccount(pxe);
    sender = await createAccount(pxe);
    recipient = await createAccount(pxe);

    console.log(pxe)

    token = await TokenContract.deploy(deployer, deployer.getCompleteAddress()).send().deployed()
    // token = await Contract.deploy(deployer, TokenArtifact, [deployer.getCompleteAddress()]).send().deployed();
    receipt_creator = await ReceiptCreatorContract.deploy(deployer, token).send().deployed();


  }, 60000);

  xit('Check Contract Deployment', async () => {
    // expect(token.completeAddress).toBeDefined()
    // expect(receipt_creator.completeAddress).toBeDefined()
  })

  xit('Generate Receipt', async () => {
    //   // distribute token to sender
    //   const initialBalance = 20n;
    const secret: Fr = Fr.random();
    //   const secretHash = await computeMessageSecretHash(secret)
    //   const receipt = await token.methods.mint_private(initialBalance, secretHash).send().wait();
    //
    //   const storageSlot = new Fr(5)
    //
  })

})
