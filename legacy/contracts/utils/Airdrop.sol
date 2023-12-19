// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title Airdrop
 * @dev Contrato para realizar un airdrop de tokens a direcciones específicas.
 */
interface ERC20 {
    /**
     * @dev Transfiere una cantidad de tokens a una dirección específica.
     * @param recipient La dirección del receptor de los tokens.
     * @param amount La cantidad de tokens a transferir.
     * @return Éxito de la transferencia.
     */
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

    /**
     * @dev Modificador para restringir el acceso solo al propietario del contrato.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    /**
     * @dev Modificador para restringir el acceso solo a direcciones autorizadas.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "You are not authorized to call this function.");
        _;
    }

    /**
     * @dev Modificador para verificar el límite de gas.
     * @param gas El límite de gas deseado.
     */
    modifier gasLimit(uint256 gas) {
        require(gas == gasleft(), "Invalid gas limit.");
        _;
    }

    /**
     * @dev Pausa el contrato. Solo puede ser llamado por el propietario.
     */
    function pause() public onlyOwner {
        paused = true;
    }

    /**
     * @dev Quita la pausa del contrato. Solo puede ser llamado por el propietario.
     */
    function unpause() public onlyOwner {
        paused = false;
    }

    /**
     * @dev Realiza el reclamo de tokens para una dirección autorizada.
     */
    function claim() public onlyWhitelisted gasLimit(GAS_LIMIT) {
        require(!paused, "The contract is paused.");
        require(!claimed[msg.sender], "You have already claimed the airdrop.");
        claimed[msg.sender] = true;
        token.transfer(msg.sender, 100 * 10 ** 18); // Transfer 100 tokens to the user's address
    }
}