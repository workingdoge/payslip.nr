use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
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

global PAYSLIP_NOTE_LEN: Field = 5;

struct PayslipNote {
  from: AztecAddress,
  to: AztecAddress,
  amount: Field,
  token: AztecAddress,
  nonce: Field,
  header: NoteHeader,
}

impl PayslipNote {
  pub fn new(
    from: AztecAddress, 
    to: AztecAddress, 
    amount: Field,  
    token: AztecAddress, 
    nonce: Field
  ) -> Self {
    PayslipNote {
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
      self.from.address, 
      self.to.address, 
      self.amount, 
      self.token.address,
      self.nonce
    ]
  }

  pub fn deserialize(serialized_note: [Field; PAYSLIP_NOTE_LEN]) -> Self {
    PayslipNote {
      from: AztecAddress::new(serialized_note[0]),
      to: AztecAddress::new(serialized_note[1]),
      amount: serialized_note[2],
      token: AztecAddress::new(serialized_note[3]),
      nonce: serialized_note[4],
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

  pub fn broadcast(self, context: &mut PrivateContext, slot: Field) {
      
    let encryption_pub_key = get_public_key(self.to.address);
   
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
