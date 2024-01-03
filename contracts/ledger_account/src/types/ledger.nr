use crate::types::taccount;

struct Ledger {
  context: Context,
  storage_slot: Field,
}

impl Ledger {
  pub fn new(
    context: Context,
    storage_slot: Field,
  ) -> Self {
    assert(storage_slot != 0, "Storage slot 0 not allowed. Storage slot must start from 1.");
    Self {
      context,
      storage_slot,
    }
  }

  pub fn at(self, account: Field,  token: AztecAddress) {
    let derived_storage_slot = pedersen_hash([self.storage_slot, token.address, account],0);
    TAccount::new(self.context, owner, derived_storage_slot)

  }


}

