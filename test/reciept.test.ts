import { AccountWallet, AztecAddress, Fr, PXE, TxStatus, Wallet, computeMessageSecretHash, createAccount, createPXEClient, Contract } from "@aztec/aztec.js";
import { TokenContract } from "@aztec/noir-contracts";
import ReceiptCreatorArtifact from "../contracts/target/ReceiptCreator.json"  assert { type: "json" };

const { PXE_URL = "http://localhost:8080" } = process.env

describe('receipt contract', () => {

  let pxe: PXE;
  let deployer: AccountWallet;
  let sender: AccountWallet;
  let recipient: AccountWallet;
  let token: TokenContract;
  let receipt_creator: Contract;


  beforeEach(async () => {

    // setup
    pxe = createPXEClient(PXE_URL);
    deployer = await createAccount(pxe);
    sender = await createAccount(pxe);
    recipient = await createAccount(pxe);
    token = await TokenContract.deploy(deployer, deployer.getCompleteAddress()).send().deployed();
    receipt_creator = await Contract.deploy(deployer, ReceiptCreatorArtifact, []).send().deployed();


  }, 60000);

  it('Check Contract Deployment', async () => {
    expect(token.completeAddress).toBeDefined()
    expect(receipt_creator.completeAddress).toBeDefined()
  })

  it('Generate Receipt', async () => {
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
