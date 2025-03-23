// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ClustToken is ERC20, Ownable, Pausable {
    uint256 public constant TRANSACTION_FEE_PERCENT = 2; // 2% transaction fee
    address public treasuryWallet;

    struct Staker {
        uint256 stakedAmount;
        uint256 stakeTimestamp;
    }

    mapping(address => Staker) public stakers;

    constructor(address _treasuryWallet) ERC20("ClustToken", "CLT") Ownable(msg.sender) {
        require(_treasuryWallet != address(0), "Treasury wallet cannot be zero address");
        treasuryWallet = _treasuryWallet;
        _mint(msg.sender, 1_000_000 * 10 ** decimals()); // Mint 1 million CLT to deployer
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != address(0), "Invalid treasury address");
        treasuryWallet = _treasuryWallet;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function stake(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(amount > 0, "Cannot stake zero tokens");

        _transfer(msg.sender, address(this), amount);
        stakers[msg.sender] = Staker(amount, block.timestamp);
    }

    function unstake() external {
        Staker storage userStake = stakers[msg.sender];
        require(userStake.stakedAmount > 0, "No tokens staked");

        uint256 stakedTime = block.timestamp - userStake.stakeTimestamp;
        uint256 reward = (userStake.stakedAmount * 10 * stakedTime) / (365 days * 100);

        _mint(msg.sender, reward);
        _transfer(address(this), msg.sender, userStake.stakedAmount);

        delete stakers[msg.sender];
    }

    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        uint256 fee = (amount * TRANSACTION_FEE_PERCENT) / 100;
        uint256 amountAfterFee = amount - fee;

        _transfer(msg.sender, treasuryWallet, fee);
        _transfer(msg.sender, recipient, amountAfterFee);

        return true;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
