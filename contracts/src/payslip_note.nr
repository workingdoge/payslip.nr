
use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
    },
//    types::address::{AztecAddress},
    hash::pedersen_hash,
    context::PrivateContext,
};
use dep::protocol_types::address::AztecAddress;

global PAYSLIP_NOTE_LEN: Field = 5;

struct PayslipNote {
  from: AztecAddress,
  to: AztecAddress,
  amount: Field,
  token: AztecAddress,
  timestamp: Field,
  header: NoteHeader,
}

impl PayslipNote {
  pub fn new(
    from: AztecAddress, 
    to: AztecAddress, 
    amount: Field,  
    token: AztecAddress, 
    timestamp: Field
  ) -> Self {
    PayslipNote {
      from,
      to,
      amount,
      token,
      timestamp,
      header: NoteHeader::empty(),
    }
  }

  pub fn serialize(self) -> [Field; PAYSLIP_NOTE_LEN] {
    [ 
      self.from.to_field(), 
      self.to.to_field(), 
      self.amount as Field, 
      self.token.to_field(),
      self.timestamp
    ]
  }

  pub fn deserialize(serialized_note: [Field; PAYSLIP_NOTE_LEN]) -> Self {
    PayslipNote {
      from: AztecAddress::from_field(serialized_note[0]),
      to: AztecAddress::from_field(serialized_note[1]),
      amount: serialized_note[2],
      token: AztecAddress::from_field(serialized_note[3]),
      timestamp: serialized_note[4],
      header: NoteHeader::empty(),
    }
  }

  pub fn compute_note_hash(self) -> Field {
    pedersen_hash(self.serialize(), 0)
  }

  // receipt cannot be nullified
  pub fn compute_nullifier(self) -> Field {
    0
  }

  pub fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
  }
}

fn deserialize(serialized_note: [Field; PAYSLIP_NOTE_LEN]) -> PayslipNote {
    PayslipNote::deserialize(serialized_note)
}

fn serialize(payslip: PayslipNote) -> [Field; PAYSLIP_NOTE_LEN] {
    payslip.serialize()
}

fn compute_note_hash(payslip: PayslipNote) -> Field {
    payslip.compute_note_hash()
}

fn compute_nullifier(payslip: PayslipNote) -> Field {
    payslip.compute_nullifier()
}

fn get_header(payslip: PayslipNote) -> NoteHeader {
    payslip.header
}

fn set_header(payslip: &mut PayslipNote, header: NoteHeader) {
    payslip.set_header(header);
}

fn broadcast(context: &mut PrivateContext, slot: Field, payslip: PayslipNote) {
    assert(false, "PayslipNote does not support broadcast. Add it to PXE directly using the `.addNote` function.");
}

global PayslipNoteMethods = NoteInterface {
    deserialize,
    serialize,
    compute_note_hash,
    compute_nullifier,
    get_header,
    set_header,
    broadcast,
};
