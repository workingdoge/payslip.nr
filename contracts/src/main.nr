mod receipt_note;

contract ReceiptCreator {
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

  use crate::receipt_note::{ReceiptNote, ReceiptNoteMethods, RECEIPT_NOTE_LEN};

  struct Storage {
     receipt: Map<ImmutableSingleton<ReceiptNote, RECEIPT_NOTE_LEN>>
   } 

  impl Storage {
    fn init(context: Context) -> Self {
      Storage {
          receipt: Map::new(
            context,
            1,
            |context, slot| {
              ImmutableSingleton::new(context, slot, ReceiptNoteMethods)
            }
          )
      } 
    }
  }

  #[aztec(private)]
  fn constructor(token: AztecAddress) {
        let selector = compute_selector("_initialize((Field))");
        context.call_public_function(context.this_address(), selector, [token.address]);
  }

  #[aztec(private)]
  fn transfer_with_receipt(token_address: Field, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field) {

    let selector = compute_selector("transfer(AztecAddress,AztecAddress,Field,Field)");

    context.call_private_function(
      token_address,
      selector,
      [from, to, amount, nonce]
    )

  }

}
