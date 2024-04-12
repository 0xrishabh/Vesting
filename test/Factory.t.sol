pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {Factory} from "src/Factory.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface IVesting {
    struct VestingInfo {
        uint256 start;
        uint256 duration;
        uint256 cliff;
        uint256 amount;
        address beneficiary;
        address token;
        uint256 claimed;
        uint256 claimable;
    }

    function claim() external;
    function vestingInfo() external view returns (VestingInfo memory info);
}

contract USDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract FactroyTest is Test {
    Factory factory;
    uint256 start;
    uint256 duration;
    uint256 cliff;
    uint256 amount;
    address token;
    address beneficiary;

    function setUp() public {
        token = address(new USDC());
        factory = new Factory();
        deal(token, address(this), 100_000e18);
    }

    function testNewVesting() public {
        start = block.timestamp;
        duration = 365 days;
        cliff = 1 days;
        amount = 1000;
        beneficiary = address(this);

        ERC20(token).approve(address(factory), amount);
        address vesting = factory.newVesting(start, duration, cliff, amount, beneficiary, token);

        IVesting.VestingInfo memory info = IVesting(vesting).vestingInfo();
        assertEq(info.start, block.timestamp);
        assertEq(info.duration, duration);
        assertEq(info.cliff, cliff);
        assertEq(info.amount, amount);
        assertEq(info.beneficiary, beneficiary);
        assertEq(info.token, token);
        assertEq(info.claimed, 0);
        assertEq(info.claimable, 0);
    }
}
