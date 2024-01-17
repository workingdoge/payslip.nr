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
    types::type_serialization::{
      field_serialization::{
        FieldSerializationMethods, FIELD_SERIALIZED_LEN
      },
      bool_serialization::{
        BoolSerializationMethods, BOOL_SERIALIZED_LEN
      }
    },
  };
    use dep::aztec::protocol_types::{
      abis::function_selector::FunctionSelector,
      address::AztecAddress,
  };

    use dep::authwit::auth::{IS_VALID_SELECTOR, assert_current_call_valid_authwit, compute_authwit_message_hash};

    use crate::payslip_note::{PayslipNote, PayslipNoteMethods, PAYSLIP_NOTE_LEN};

    struct Storage {
payslips: Map<AztecAddress, Set<PayslipNote, PAYSLIP_NOTE_LEN>>,
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
        //context.call_public_function(context.this_address(), compute_selector("_initialize()"), []);
    }

    #[aztec(private)]
    fn transfer_and_mint_payslip(token: AztecAddress, from: AztecAddress, to: AztecAddress, amount: Field, nonce: Field) {
        // transfer tokens
        context.call_private_function(
            token.address,
            FunctionSelector::from_signature("transfer((Field),(Field),Field,Field)"),
            [from.address, to.address, amount, nonce]
        );
        // Does it make sense to just commit to the hash of the inputs to the function instead?
        let mut from_payslip = PayslipNote::new(from, from, to, amount, token, nonce);
        let mut to_payslip = PayslipNote::new(to, from, to, amount, token, nonce);
        storage.payslips.at(from.address).insert(&mut from_payslip, false);
        storage.payslips.at(to.address).insert(&mut to_payslip, false);
    }

    #[aztec(public)]
    internal fn _initialize() {}

    unconstrained  fn compute_note_hash_and_nullifier(
        contract_address: Field,
        nonce: Field,
        storage_slot: Field,
        serialized_note: [Field; 4]
    ) -> pub [Field; 4] {
        let note_header = NoteHeader::new(
            AztecAddress::from_field(contract_address),
            nonce,
            storage_slot
        );
        note_utils::compute_note_hash_and_nullifier(PayslipNoteMethods, note_header, serialized_note)
    }
}
