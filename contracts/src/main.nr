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
      public_state::PublicState
    },

    types::address::{AztecAddress},
    types::type_serialization::{
      field_serialization::{
        FieldSerializationMethods, FIELD_SERIALIZED_LEN
      },
      bool_serialization::{
        BoolSerializationMethods, BOOL_SERIALIZED_LEN
      }
    },

    selector::compute_selector,
  };

  use dep::authwit::auth::{IS_VALID_SELECTOR, assert_current_call_valid_authwit, compute_authwit_message_hash};

  use crate::payslip_note::{PayslipNote, PayslipNoteMethods, PAYSLIP_NOTE_LEN};

  struct Storage {
    payslips: Map<ImmutableSingleton<PayslipNote, PAYSLIP_NOTE_LEN>>,
   } 

  
  impl Storage {
   fn init(context: Context) -> Self {
    Storage {
      payslips: Map::new(
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
  fn transfer_and_mint_payslip(
      token: AztecAddress, 
      from: AztecAddress, 
      to: AztecAddress,
      amount: Field,
      nonce: Field,
      timestamp: Field,
    ) {

        // context.timestamp can only be called in a public context 
        // assert the supplied timestamp is accurate
        context.call_public_function(
            context.this_address(),
            compute_selector("_assert_timestamp_is_same(Field)"),
            [timestamp]
        );


        // transfer tokens
        context.call_private_function(
            token.address,
            compute_selector("transfer((Field),(Field),Field,Field)"),
            [from.address, to.address, amount, nonce]
         );

       
        let payslip = PayslipNote::new(
               token.address, 
               from.address, 
               to.address, 
               amount, 
               timestamp
             );
   

         //storage.payslips.at(to).initialize(payslip);
        

  }

  #[aztec(public)]
  internal fn _assert_timestamp_is_same(time: Field) {
     assert(context.timestamp() == time);
  }


  //#[aztec(public)]
  //internal fn _approve_token(token: AztecAddress, from: AztecAddress, to: AztecAddress, amount: Field ) {
  //  let nonce = storage.nonce_for_approvals.read();
  //  let selector = compute_selector("transfer((Field),(Field),Field,Field)");

  //  let message_hash = 
  //    compute_authwit_message_hash(
  //      from,
  //      token,
  //      selector,
  //      [from.address, to.address, amount, nonce] 
  //    );


  //   storage.approvals.at(message_hash).write(true);

  //   storage.nonce_for_approvals.write(nonce + 1);
  //}

 // fn transfer_with_receipt_note(token_address: Field, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field) {
 //}

unconstrained fn compute_note_hash_and_nullifier(contract_address: Field, nonce: Field, storage_slot: Field, serialized_note: [Field; 0]) -> [Field; 4] {
        [0, 0, 0, 0]
    }

}
