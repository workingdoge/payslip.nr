mod payslip_note;

contract Payslip {
    use dep::std::option::Option;
    use dep::safe_math::SafeU120;
    use dep::aztec::{

    context::{PrivateContext, PublicContext, Context},

    note::{
      note_header::NoteHeader,
      utils as note_utils,
    },

    state_vars::{
      map::Map,
      singleton::Singleton,
      set::Set
    },

    hash::pedersen_hash,

//    history::prove_note_validity,

    types::address::AztecAddress,
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

 //   use dep::value_note::value_note::{ValueNote, ValueNoteMethods, VALUE_NOTE_LEN};

    use dep::authwit::auth::{IS_VALID_SELECTOR, assert_current_call_valid_authwit, compute_authwit_message_hash};

    use crate::payslip_note::{PayslipNote, PayslipNoteMethods, PAYSLIP_NOTE_LEN};

    struct Storage {
    payslips: Map<Set<PayslipNote, PAYSLIP_NOTE_LEN>>,
//    safety_score: Map<Singleton<ValueNote, PAYSLIP_NOTE_LEN>>,
   }

    impl Storage {
   fn init(context: Context) -> Self {
    Storage {
          payslips: Map::new(
            context,
            1,
            |context, slot| {
              Set::new(context, slot, PayslipNoteMethods)
            }
          )
      }
    }
  }

    #[aztec(private)]
    fn constructor() {
        context.call_public_function(context.this_address(), compute_selector("_initialize()"), []);
    }

    #[aztec(private)]
    fn transfer_and_mint_payslip(token: AztecAddress, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field) {
        // transfer tokens
        context.call_private_function(
            token.address,
            compute_selector("transfer((Field),(Field),Field,Field)"),
            [from.address, to.address, amount, nonce]
        );

        let mut payslip = PayslipNote::new(from, to, amount, token, nonce);

        let from_storage = storage.payslips.at(from.address);
        let to_storage = storage.payslips.at(to.address);

        from_storage.insert(&mut payslip, false);
        to_storage.insert(&mut payslip, false);
    }

    #[aztec(private)]
    fn compute_safety_score(address: AztecAddress, block_number: u32) {}

    #[aztec(private)]
    fn from_sender() {}

  //  #[aztec(private)]
  //internal fn _validate_payslip_note(block_number: u32, payslip: PayslipNote) {
  //      prove_note_validity(payslip.interface, note, block_number, context)
  //  }

    #[aztec(public)]
  internal fn _initialize() {
        //storage.counter.write(0);
    }

    unconstrained fn compute_note_hash_and_nullifier(
        contract_address: Field,
        nonce: Field,
        storage_slot: Field,
        serialized_note: [Field; 4]
    ) -> [Field; 4] {
        [0, 0, 0, 0]
    }
}
