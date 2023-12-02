import 'solana';
import { Verifier } from './verifier.sol';
import { simpler_storage } from './simpler_storage.sol';


@program_id("2sB1sNVQ412kzS5JkNhBCrg33BMvyV3q9Tvq1LzBJBXn") // on-chain program address
contract verifier_user {
    address public _verifier;

    @payer(payer)
    constructor() {}

    function setVerifier(address verifier) public {
        _verifier = verifier;
    }

    function getVerifier() public view returns (address) {
        return address(_verifier);
    }

    function verify() external view returns (bool) {
        return Verifier.testGetter();
    }

    function callRust() external view returns (uint64) {
        return simpler_storage.viewFunction();
    }
}
