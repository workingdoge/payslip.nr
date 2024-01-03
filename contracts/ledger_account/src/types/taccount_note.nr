use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
        utils::compute_note_hash_for_read_or_nullify,
    },
    log::emit_encrypted_log,
    oracle::{
        rand::rand,
        get_secret_key::get_secret_key,
        get_public_key::get_public_key,
    },
    types::address::AztecAddress,
    hash::pedersen_hash,
    context::PrivateContext,
};

use dep::safe_math::SafeU120;

global TACCOUNT_NOTE_LEN: Field = 4;

struct TAccountNote {
  debit: SafeU120,
  credit: SafeU120,
  owner: AztecAddress,
  randomness: Field,
  header: NoteHeader,
}

impl TAccountNote {
  pub fn new(owner: AztecAddress) -> Self {
    Self {
        debit: SafeU120::new(0),
        credit: SafeU120::new(0),
        owner,
        randomness: rand(),
        header: NoteHeader::empty(),
    }
  }

  pub fn serialize(self) -> [Field; TACCOUNT_NOTE_LEN] {
    [ 
      self.debit.value as Field, 
      self.credit.value as Field, 
      self.owner.address as Field, 
      self.randomness,
    ]
  }

  pub fn deserialize(serialized_note: [Field; TACCOUNT_NOTE_LEN]) -> Self {
    Self {
      debit: SafeU120::new(serialized_note[0]),
      credit: SafeU120::new(serialized_note[1]),
      owner: AztecAddress::new(serialized_note[2]),
      randomness: serialized_note[3],
      header: NoteHeader::empty(),
    }
  }

  pub fn compute_note_hash(self) -> Field {
    pedersen_hash(self.serialize(), 0)
  }

  pub fn compute_nullifier(self) -> Field {
    let note_hash_for_nullify = compute_note_hash_for_read_or_nullify(TAccountNoteMethods, self);
    let secret = get_secret_key(self.owner.address);
    pedersen_hash([
      note_hash_for_nullify,
      secret.low,
      secret.high
    ],0)
  }

  pub fn set_header(&mut self, header: NoteHeader) {
    self.header = header;
  }

  pub fn broadcast(self, context: &mut PrivateContext, slot: Field) {
    let encryption_pub_key = get_public_key(self.owner.address);
    emit_encrypted_log(
      context,
      (*context).this_address(),
      slot,
      encryption_pub_key,
      self.serialize(),
    );

  }
}

fn deserialize(serialized_note: [Field; TACCOUNT_NOTE_LEN]) -> TAccountNote {
    TAccountNote::deserialize(serialized_note)
}

fn serialize(tacc: TAccountNote) -> [Field; TACCOUNT_NOTE_LEN] {
    tacc.serialize()
}

fn compute_note_hash(tacc: TAccountNote) -> Field {
    tacc.compute_note_hash()
}

fn compute_nullifier(tacc: TAccountNote) -> Field {
    tacc.compute_nullifier()
}

fn get_header(tacc: TAccountNote) -> NoteHeader {
    tacc.header
}

fn set_header(tacc: &mut TAccountNote, header: NoteHeader) {
    tacc.set_header(header)
}

fn broadcast(context: &mut PrivateContext, slot: Field, tacc: TAccountNote) {
    tacc.broadcast(context, slot);
}

global TAccountNoteMethods = NoteInterface {
    deserialize,
    serialize,
    compute_note_hash,
    compute_nullifier,
    get_header,
    set_header,
    broadcast,
};
