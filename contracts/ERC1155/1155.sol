// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/ERC1155/ERC1155.sol";
import "./IERC1155.sol";


contract NFT1155 is ERC1155, AccessControl {

    IERC1155 public Token;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
   

    constructor() ERC1155() {
       _setupRole(MINTER_ROLE, msg.sender);
       _setupRole(MINTER_ROLE,address(this));
       _setupRole(BURNER_ROLE,msg.sender);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

   
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, tokenId, amount, "");
    }

    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        _burn(from, tokenId, amount);
    }

    function setURI(uint256 tokenId, string memory newuri) external onlyRole(MINTER_ROLE) {
        _setURI(tokenId,newuri);
    }

    
}
