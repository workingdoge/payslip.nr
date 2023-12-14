
use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
    },
    hash::pedersen_hash,
    context::PrivateContext,
};

global RECEIPT_NOTE_LEN: Field = 5;

struct ReceiptNote {
  amount: Field,
  from: Field,
  to: Field,
  token_address: Field,
  timestamp: Field,
  header: NoteHeader,
}

impl ReceiptNote {
  pub fn new(amount: Field, from: Field, to: Field, token_address: Field, timestamp: Field) -> Self {
    ReceiptNote {
      amount,
      from,
      to,
      token_address,
      timestamp,
      header: NoteHeader::empty(),
    }
  }

  pub fn serialize(self) -> [Field; RECEIPT_NOTE_LEN] {
    [ self.amount, self.from, self.to, self.token_address, self.timestamp ]
  }

  pub fn deserialize(serialized_note: [Field; RECEIPT_NOTE_LEN]) -> Self {
    ReceiptNote {
      amount: serialized_note[0],
      from: serialized_note[1],
      to: serialized_note[2],
      token_address: serialized_note[3],
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

fn deserialize(serialized_note: [Field; RECEIPT_NOTE_LEN]) -> ReceiptNote {
    ReceiptNote::deserialize(serialized_note)
}

fn serialize(receipt: ReceiptNote) -> [Field; RECEIPT_NOTE_LEN] {
    receipt.serialize()
}

fn compute_note_hash(receipt: ReceiptNote) -> Field {
    receipt.compute_note_hash()
}

fn compute_nullifier(receipt: ReceiptNote) -> Field {
    receipt.compute_nullifier()
}

fn get_header(receipt: ReceiptNote) -> NoteHeader {
    receipt.header
}

fn set_header(receipt: &mut ReceiptNote, header: NoteHeader) {
    receipt.set_header(header);
}

fn broadcast(context: &mut PrivateContext, slot: Field, receipt: ReceiptNote) {

    assert(false, "ReceiptNote does not support broadcast. Add it to PXE directly using the `.addNote` function.");
}

global ReceiptNoteMethods = NoteInterface {
    deserialize,
    serialize,
    compute_note_hash,
    compute_nullifier,
    get_header,
    set_header,
    broadcast,
};
