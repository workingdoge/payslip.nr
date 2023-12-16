mod payslip_note;

contract Payslip {
  use dep::std;

  use dep::aztec::{
    context::{PrivateContext, PublicContext, Context},
    note::{
      note_header::NoteHeader,
      utils as note_utils,
    },
    state_vars::{
      map::Map,
      immutable_singleton::ImmutableSingleton,
    },
    types::address::{AztecAddress},
    selector::compute_selector,
  };

  use dep::authwit::{
      auth::{
          assert_current_call_valid_authwit,
          assert_current_call_valid_authwit_public,
      },
  };

  use crate::payslip_note::{PayslipNote, PayslipNoteMethods, PAYSLIP_NOTE_LEN};

  struct Storage {
     receipt: Map<ImmutableSingleton<PayslipNote, PAYSLIP_NOTE_LEN>>
   } 

  
  impl Storage {
   fn init(context: Context) -> Self {
    Storage {
      receipt: Map::new(
        context,
        1,
            |context, slot| {
              ImmutableSingleton::new(context, slot, PayslipNoteMethods)
            }
          )
      } 
    }
  }

  #[aztec(private)]
  fn constructor() {
  }
  //fn constructor(token: AztecAddress) {
  //      let selector = compute_selector("_initialize((Field))");
  //      context.call_public_function(context.this_address(), selector, []);
  //}

  #[aztec(private)]
  fn transfer_with_payslip(token_address: Field, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field) {

    let selector = compute_selector("transfer(AztecAddress,AztecAddress,Field,Field)");

    context.call_private_function(
      token_address,
      selector,
      [from.address, to.address, amount, nonce]
    )


  }

 // fn transfer_with_receipt_note(token_address: Field, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field) {
 //}

unconstrained fn compute_note_hash_and_nullifier(contract_address: Field, nonce: Field, storage_slot: Field, serialized_note: [Field; 0]) -> [Field; 4] {
        [0, 0, 0, 0]
    }

}
