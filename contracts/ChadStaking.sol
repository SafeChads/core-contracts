//SPDX-License-Identifier: MIT
pragma solidity =0.7.3;

import "./SafeChadBEP20.sol";
import "./libraries/SafeMath.sol";

contract ChadStaking is SafeChadBEP20 {
    using SafeMath for uint;

    ISafeChadBEP20 public chad;

    constructor(ISafeChadBEP20 _chad) SafeChadBEP20("SafeChad Staking", "xCHAD") {
      chad = _chad;
    }

    function pendingChad(address who) external view returns (uint256) {
        uint256 totalShares = totalSupply;
        uint256 what = balanceOf[who].mul(chad.balanceOf(address(this))) / (totalShares);

        return what;
    }

    function mint(uint256 value) external {
        uint256 totalChad = chad.balanceOf(address(this));
        uint256 totalShares = totalSupply;

        if (totalShares == 0 || totalChad == 0) {
            _mint(msg.sender, value);
        } 
        else {
            uint256 what = value.mul(totalShares) / (totalChad);
            _mint(msg.sender, what);
        }
        chad.transferFrom(msg.sender, address(this), value);
    }

    function burn(uint256 value) external {
        uint256 totalShares = totalSupply;
        uint256 what = value.mul(chad.balanceOf(address(this))) / (totalShares);

        _burn(msg.sender, value);
        chad.transfer(msg.sender, what);      
    }
}