use crate::types::taccount_note{TAccountNote, TACCOUNT_NOTE_LEN, TAccountNoteMethods};
use dep::safe_math::SafeU120;

use dep::aztec::{
  context::{PrivateContext, Context},
  state_vars::singleton::Singleton,
};

struct TAccount {
  context: Context,
  owner: AztecAddress,
  note: Singleton<TAccountNote, TACCOUNT_NOTE_LEN>
}

impl TAccountSingleton {
  pub fn new(context: Context, owner: AztecAddress, storage_slot: Field) -> Self {
    assert(storage_slot != 0, "Storage slot 0 not allowed. Storage slots must start from 1.");
    let tacc = Singleton {
      context,
      storage_slot,
      note_interface: TAccountNoteMethods,
    };
    Self {
      context,
      owner,
      tacc
    }
  }

  pub fn update(self: Self, debit: SafeU120, credit: SafeU120) {

    let mut tacc = self.tacc.get_note(false);
    let new_debit = tacc.debit + debit;
    let new_credit = tacc.credit + credit;
    let min = TAccountSingleton::min(debit, credit);

    tacc.debit = new_debit - min;
    tacc.credit = new_credit - min;

    self.tacc.replace(tacc, false);
  }

  unconstrained fn min(x:SafeU120, y:SafeU120) -> SafeU120 {
    let mut min: SafeU120 = 0;
    if x < y {
      min = x;
    } else {
      min = y;
    }

  }
}

