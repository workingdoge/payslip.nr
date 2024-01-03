mod taccount;

contract LedgerAccount {
    use dep::std;
    use dep::aztec::{
       abi::{ PrivateCircuitPublicInputs, PrivateContextInputs, Hasher },
       types::{ vec::BoundedVec, point::Point },
       context::PrivateContext,
     };

    use dep::authwit:: {
       entrypoint::{ EntrypointPayload, ENTRYPOINT_PAYLOAD_SIZE },
       account::AccountActions,
       auth_witness::get_auth_witness,
     };

    global public_key_x: Field = 0x0ede3d33c920df8fdf43f3e39ed38b0882c25b056620ef52fd016fe811aa2443;
    global public_key_y: Field = 0x29155934ffaa105323695b5f91faadd84acc21f4a8bda2fad760f992d692bc7f;

    global ACCOUNT_ACTIONS_STORAGE_SLOT = 1;

    #[aztec(private)]
    fn constructor() {
        //context.call_public_function(context.this_address(), compute_selector("_initialize()"), []);
    }
}
