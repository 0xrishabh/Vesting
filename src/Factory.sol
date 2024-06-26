pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Factory {
    using SafeERC20 for IERC20;

    event Vesting(
        address vestAddress,
        uint256 start,
        uint256 duration,
        uint256 cliff,
        uint256 amount,
        address beneficiary,
        address token
    );

    function newVesting(
        uint256 start,
        uint256 duration,
        uint256 cliff,
        uint256 amount,
        address beneficiary,
        address token
    ) external returns (address addr) {
        bytes memory args = abi.encode(start, duration, cliff, amount, beneficiary, token);
        bytes memory bytecode =
            hex"600b80380380913d393df35f3560e01c806320df13441461001e5780634e71d92d146100ee575f5ffd5b602060c03803600039600051602060a0380360203960205160206080380360403960405160206060380360603960605160206040380360803960805160206020380360a03960a0515f5460c05260206060380361010439610104516020608038036101183961011851602060a0380361012c3961012c51602060c03803610140396101405180420383116001146100d2578042106001146100d25780820142116001146100dd5742038302049150506100e5565b5050505060006100e5565b5050506100e5565b60e0526101585ff35b7fa9059cbb0000000000000000000000000000000000000000000000000000000060205260206040380360003960005160245260206060380361010439610104516020608038036101183961011851602060a0380361012c3961012c51602060c03803610140396101405180420383116001146101885780421060011461018857808201421160011461019357420383020491505061019b565b50505050600061019b565b50505061019b565b60445260206020604460205f6020602038036000396000515af16020516001143d1517166101c7575f80fd5b5f5ff3";
        bytecode = abi.encodePacked(bytecode, args);
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        IERC20(token).safeTransferFrom(msg.sender, addr, amount);
        emit Vesting(addr, start, duration, cliff, amount, beneficiary, token);
    }
}
