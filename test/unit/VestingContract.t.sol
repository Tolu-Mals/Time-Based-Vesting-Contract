import {Test} from "forge-std/Test.sol";
import {DeployVestifyToken} from "script/DeployVestifyToken.s.sol";
import {DeployVestifyContract} from "src/DepoyVestifyContract";
import {VestifyToken} from "src/VestifyToken.sol";
import {VestifyContract} from "src/VestifyContract.sol";

contract VestingContractTest is Test {
    function setUp() external {}

    function testThatCorrectTokenAddressIsStored() public view {
        DeployVestifyToken vestifyTokenDeployer = new DeployVestifyToken();
        VestifyToken vestifyToken = new VestifyToken();

        DeployVestifyContract vestifyContractDeployer = new DeployVestifyContract();
        VestifyContract vestifyContract = new VestifyContract(
            address(vestifyToken)
        );

        assert(
            vestifyContract.getVestifyTokenContract() == address(vestifyToken)
        );
    }
}
