pragma solidity =0.7.3;

import "./SafeChadBEP20.sol";
import "./libraries/SafeMath.sol";
import "./libraries/Ownable.sol";

contract SafeChad is SafeChadBEP20, Ownable {
    using SafeMath for uint;

    address public liquidityPool;  

    address public chadStaking;
    uint96 public tax;

    event TaxApplied(address from, uint256 taxValue);

    constructor(uint96 _tax) SafeChadBEP20("SafeChad", "CHAD") {
        /// tax must be <= 1000 to be valid
        require(_tax <= 1000, "SafeChad: invalid tax");

        tax = _tax;

        _mint(msg.sender, 1000000000000000000000);
    }

    function _transfer(address from, address to, uint256 value) internal override {
        uint256 correctedValue;
        if (to == liquidityPool) {
            correctedValue = value.mul(tax) / 1000;
            uint256 taxValue = value.sub(correctedValue);
        
            _burn(from, taxValue);
            _mint(chadStaking, taxValue / 2);

            emit TaxApplied(from, taxValue);
        } else {
            correctedValue = value;
        }

        balanceOf[from] = balanceOf[from].sub(correctedValue);
        balanceOf[to] = balanceOf[to].add(correctedValue);

        emit Transfer(from, to, value);
    }

    function changeTax(uint96 _tax) external onlyOwner {
        /// tax must be <= 1000 to be valid
        require(_tax <= 1000, "SafeChad: invalid tax");
        tax = _tax;      
    }

    function setLiquidityPool(address _liquidityPool) external onlyOwner {
        require(_liquidityPool != address(0));
        liquidityPool = _liquidityPool;
    }

    function setStake(address _chadStaking) external onlyOwner {
        require(_chadStaking != address(0));
        chadStaking = _chadStaking;
    }
    
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}