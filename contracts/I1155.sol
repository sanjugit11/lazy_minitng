// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/ERC1155/IERC1155.sol";
interface I1155 is IERC1155{

function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external;

    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external;
 
    function setURI(uint256 tokenId, string memory newuri) external; 

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) external ;
  
}