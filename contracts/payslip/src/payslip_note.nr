use dep::aztec::protocol_types::{
  address::AztecAddress
};

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
    hash::pedersen_hash,
    context::PrivateContext,
};

global PAYSLIP_NOTE_LEN: Field = 6;

struct PayslipNote {
  owner: AztecAddress,
  from: AztecAddress,
  to: AztecAddress,
  amount: Field,
  token: AztecAddress,
  nonce: Field,
  header: NoteHeader,
}

impl PayslipNote {
  pub fn new(
    owner: AztecAddress,
    from: AztecAddress, 
    to: AztecAddress, 
    amount: Field,  
    token: AztecAddress, 
    nonce: Field
  ) -> Self {
    PayslipNote {
      owner,
      from,
      to,
      amount,
      token,
      nonce,
      header: NoteHeader::empty(),
    }
  }

  pub fn serialize(self) -> [Field; PAYSLIP_NOTE_LEN] {
    [ 
      self.owner.to_field(),
      self.from.to_field(), 
      self.to.to_field(), 
      self.amount, 
      self.token.to_field(),
      self.nonce
    ]
  }

  pub fn deserialize(serialized_note: [Field; PAYSLIP_NOTE_LEN]) -> Self {
    PayslipNote {
      owner: AztecAddress::from_field(serialized_note[0]),
      from: AztecAddress::from_field(serialized_note[1]),
      to: AztecAddress::from_field(serialized_note[2]),
      amount: serialized_note[3],
      token: AztecAddress::from_field(serialized_note[4]),
      nonce: serialized_note[5],
      header: NoteHeader::empty(),
    }
  }

  pub fn compute_note_hash(self) -> Field {
    pedersen_hash(self.serialize(), 0)
  }

  // receipt cannot be nullified
  pub fn compute_nullifier(self) -> Field {
    let note_hash_for_nullify = compute_note_hash_for_read_or_nullify(PayslipNoteMethods, self);
    let secret = get_secret_key(self.owner);
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
      
    let encryption_pub_key = get_public_key(self.to);
   
    emit_encrypted_log(
      context,
      (*context).this_address(),
      slot,
      encryption_pub_key,
      self.serialize(),
    );
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
    payslip.set_header(header)
}

fn broadcast(context: &mut PrivateContext, slot: Field, payslip: PayslipNote) {
    payslip.broadcast(context, slot);
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
