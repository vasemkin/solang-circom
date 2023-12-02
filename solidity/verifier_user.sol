import 'solana';


@program_id("2sB1sNVQ412kzS5JkNhBCrg33BMvyV3q9Tvq1LzBJBXn") // on-chain program address
contract verifier_user {
    address private _verifier;

    @payer(payer)
    constructor() {
        print("Hello, World!");
    }

    function setVerifier(address verifier) public {
        _verifier = verifier;
    }

    function getVerifier() public view returns (address) {
        return _verifier;
    }

}
