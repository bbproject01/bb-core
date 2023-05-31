// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Contrato de Fungible Non-Fungible Tokens (FNFT)
 * @author Su nombre
 * @notice Este contrato permite a los usuarios emitir FNFTs que representan diferentes productos o activos financieros.
 */
contract FNFT is ERC1155 {
    using SafeMath for uint256;

    IERC20 public erc20Token;  // El token ERC20 que se requiere para interactuar con este contrato
    uint256 public tokenIdCounter; // Contador para generar ID de tokens únicos

    struct FNFTMetadata {
        uint256 originalTerm;
        uint256 timePassed;
        uint256 maximumReduction;
    }

    mapping (uint256 => FNFTMetadata) public fnftMetadata;

    /**
     * @notice Constructor del contrato FNFT.
     * @param _erc20Address La dirección del token ERC20 que se requiere para interactuar con este contrato.
     */
    constructor(address _erc20Address) ERC1155("https://token-uri.com/") {
        erc20Token = IERC20(_erc20Address);
        tokenIdCounter = 0;
    }

    /**
     * @notice Permite a un usuario acuñar un nuevo FNFT.
     * @param amount La cantidad del FNFT que se acuñará.
     * @param originalTerm El plazo original del FNFT.
     * @param maximumReduction La reducción máxima del plazo original.
     */
    function mint(uint256 amount, uint256 originalTerm, uint256 maximumReduction) external {
        require(erc20Token.balanceOf(msg.sender) >= 1000, "ERC20 balance too low");

        uint256 newTokenId = tokenIdCounter;
        tokenIdCounter = tokenIdCounter.add(1);

        _mint(msg.sender, newTokenId, amount, "");

        FNFTMetadata memory newMetadata = FNFTMetadata({
            originalTerm: originalTerm,
            timePassed: 0,
            maximumReduction: maximumReduction
        });

        fnftMetadata[newTokenId] = newMetadata;
    }

    /**
     * @notice Permite a un usuario actualizar el tiempo transcurrido de su FNFT.
     * @param tokenId El ID del FNFT.
     * @param time El nuevo tiempo transcurrido.
     */
    function updateTimePassed(uint256 tokenId, uint256 time) external {
        require(balanceOf(msg.sender, tokenId) > 0, "Sender does not own this token");

        fnftMetadata[tokenId].timePassed = time;
    }

    /**
     * @notice Calcula y devuelve el período de devolución revisado de un FNFT.
     * @param tokenId El ID del FNFT.
     * @return El período de devolución revisado.
     */
    function revisedReturnPeriod(uint256 tokenId) public view returns (uint256) {
        FNFTMetadata memory metadata = fnftMetadata[tokenId];

        return (metadata.originalTerm - metadata.timePassed) * (1 - metadata.maximumReduction);
    }
}
