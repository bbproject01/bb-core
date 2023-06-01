pragma solidity ^0.8.0;

interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    ERC20 public token;
    mapping(address => bool) public claimed;
    mapping(address => bool) public whitelist;
    bool public paused;
    address public owner;
    uint256 public constant GAS_LIMIT = 300000;

    constructor(address[] memory _whitelist, address _token) {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
        token = ERC20(_token);
        paused = false;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "You are not authorized to call this function.");
        _;
    }

    modifier gasLimit(uint256 gas) {
        require(gas == gasleft(), "Invalid gas limit.");
        _;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function claim() public onlyWhitelisted gasLimit(GAS_LIMIT) {
        require(!paused, "The contract is paused.");
        require(!claimed[msg.sender], "You have already claimed the airdrop.");
        claimed[msg.sender] = true;
        token.transfer(msg.sender, 100 * 10 ** 18); // Transfer 100 tokens to the user's address
    }
}