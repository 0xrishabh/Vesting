pragma solidity ^0.8.24;

import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
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

contract VestingTest is Test {
    IVesting vesting;
    USDC token;
    uint256 start;
    uint256 duration;
    uint256 cliff;
    uint256 amount;
    address beneficiary;

    function setUp() public {
        token = new USDC();
        start = block.timestamp;
        duration = 365 days;
        cliff = 1 days;
        amount = 1000;
        beneficiary = address(this);

        // vm.expectEmit(false, false, false, false);
        // emit Vest(start, duration, cliff, amount, beneficiary, token);
        address addr = HuffDeployer.config().with_args(
            bytes.concat(
                abi.encode(start),
                abi.encode(duration),
                abi.encode(cliff),
                abi.encode(amount),
                abi.encode(beneficiary),
                abi.encode(address(token))
            )
        ).deploy("Vesting");

        vesting = IVesting(addr);
        token.mint(addr, 1000000);

        IVesting.VestingInfo memory info = vesting.vestingInfo();
        assertEq(info.start, block.timestamp);
        assertEq(info.duration, duration);
        assertEq(info.cliff, cliff);
        assertEq(info.amount, amount);
        assertEq(info.beneficiary, beneficiary);
        assertEq(info.token, address(token));
        assertEq(info.claimed, 0);
        assertEq(info.claimable, 0);
    }

    function testVestingInfo() external {
        vm.warp(block.timestamp + 5 days);
        IVesting.VestingInfo memory info = vesting.vestingInfo();
        assertEq(info.claimable, (info.amount * (block.timestamp - info.start)) / info.duration);
        assertEq(info.claimed, 0);
    }

    function testClaim(uint256 _days) external {
        vm.assume(_days <= duration);
        vm.warp(block.timestamp + _days);
        IVesting.VestingInfo memory info = vesting.vestingInfo();
        vesting.claim();
        assertEq(ERC20(info.token).balanceOf(info.beneficiary), info.claimable);
    }
}
