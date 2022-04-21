// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "contracts/ERC1155/ERC1155.sol";
// import "contracts/draft-EIP712.sol";
// import "contracts/upgradeability/CustomOwnable.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract LazzyMinting is AccessControl,EIP712("LazyNFT-Voucher", "1"),ERC1155{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "LazyNFT-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    mapping (address => uint256) pendingWithdrawals;

    constructor(address payable minter){
        _setupRole(MINTER_ROLE, minter);
    }

    struct NFTVoucher {
        uint256 tokenId;
        uint160 Address;
        uint160 Amount;
        string uri;
        bytes signature;
    }


    function _hash(NFTVoucher calldata voucher) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "NFTVoucher(uint256 tokenId,uint160 wallet,uint160 Amount,string uri)"
                        ),
                        voucher.tokenId,
                        voucher.Address,
                        voucher.Amount,
                        keccak256(bytes(voucher.uri))
                    )
                )
            );
    }
    function _verify(NFTVoucher calldata voucher)
        internal
        view
        returns (address)
    {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }

    function redeem(address redeemer, NFTVoucher calldata voucher) public returns (uint256) {
    address signer = _verify(voucher);
    require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");
    _mint(signer, voucher.tokenId,voucher.Amount,"");
    _setURI(voucher.tokenId, voucher.uri);
    //_transfer(signer, redeemer, voucher.tokenId);
    return voucher.tokenId;
  }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl,ERC1155) returns (bool){
       super.supportsInterface(interfaceId);
    }
    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function conversion(address to) public pure returns (uint160) {
        return (uint160(to));
    }

}