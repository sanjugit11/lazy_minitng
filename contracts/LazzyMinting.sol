// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "./ERC1155/IERC1155.sol";
import "./ERC1155/1155.sol";
import "./I1155.sol";
import "hardhat/console.sol";

contract LazzyMinting is AccessControl, EIP712("LazyNFT-Voucher", "1") {
    uint256 public price;
    uint256 public Royalty;
    uint256 public value;
    uint256 public OwnerRoyalty;
    address public Creator;

    I1155 public NFT;

    mapping(uint256 => uint256) public OwnerCount;
    mapping(uint256 => mapping(uint256 => address)) public OwnerAddress;
    mapping(uint256 => bool) public VOUCHERcount;

    event transfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 tokenamount,
        uint256 amount
    );

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "LazyNFT-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    constructor(address payable minter, address _NFT) {
        NFT = I1155(_NFT);
        _setupRole(MINTER_ROLE, minter);
        _setupRole(DEFAULT_ADMIN_ROLE, minter);
    }

    struct NFTVoucher {
        uint256 tokenId;
        uint160 Address;
        uint160 Amount;
        string uri;
        bytes signature;
    }

    struct SELLVoucher {
        uint256 tokenId;
        uint160 Address;
        uint160 Amount;
        string uri;
        uint256 voucherCount;
        bytes signature;
    }

    //  struct exampleVoucher {
    //     uint256 tokenId;
    //     uint160 Address;
    //     uint160 Amount;
    //     string uri;
    //     bytes signature;
    // }

    function _hash(NFTVoucher calldata voucher) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "NFTVoucher(uint256 tokenId,uint160 Address,uint256 Amount,string uri)"
                        ),
                        voucher.tokenId,
                        voucher.Address,
                        voucher.Amount,
                        keccak256(bytes(voucher.uri))
                    )
                )
            );
    }

    function _hash2(SELLVoucher calldata voucher)
        public
        view
        returns (bytes32)
    {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "SELLVoucher(uint256 tokenId,uint160 Address,uint256 Amount,string uri,uint256 voucherCount)"
                        ),
                        voucher.tokenId,
                        voucher.Address,
                        voucher.Amount,
                        voucher.voucherCount,
                        keccak256(bytes(voucher.uri))
                    )
                )
            );
    }

    //     function _hash3(exampleVoucher calldata voucher) public view returns (bytes32) {
    //     return
    //         _hashTypedDataV4(
    //             keccak256(
    //                 abi.encode(

    //                     keccak256(
    //                         "SELLVoucher(uint256 tokenId,uint160 Address,uint256 Amount,string uri)"
    //                     ),
    //                     voucher.tokenId,
    //                     voucher.Address,
    //                     voucher.Amount,
    //                     keccak256(bytes(voucher.uri))

    //                 )
    //             )
    //         );
    // }
    //////////verify/////////////////////
    function _verify(NFTVoucher calldata voucher)
        internal
        view
        returns (address)
    {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
        // console.log(ECDSA.recover(digest,voucher.signature),"this is verify voucher");
    }

    ///2//
    function _verify2(SELLVoucher calldata voucher)
        internal
        view
        returns (address)
    {
        bytes32 digest = _hash2(voucher);
        return ECDSA.recover(digest, voucher.signature);
        // console.log(ECDSA.recover(digest,voucher.signature),"this is verify voucher");
    }

    ///3//
    //  function _verify3(exampleVoucher calldata voucher)
    //     internal
    //     view
    //     returns (address)
    // {
    //     bytes32 digest = _hash3(voucher);
    //     return ECDSA.recover(digest,voucher.signature);
    //     // console.log(ECDSA.recover(digest,voucher.signature),"this is verify voucher");
    // }
    ////////////basic funtion///////////
    function redeem(NFTVoucher calldata voucher) public returns (uint256) {
        address signer = _verify(voucher);
        require(
            voucher.Address == conversion(msg.sender),
            "unauthorized Access"
        );
        console.log(signer, "this signer from redeem");
        require(
            hasRole(MINTER_ROLE, signer),
            "Signature invalid or unauthorized"
        );
        OwnerCount[voucher.tokenId]++;
        OwnerAddress[voucher.tokenId][OwnerCount[voucher.tokenId]] = address(
            voucher.Address
        );
        NFT.mint(address(voucher.Address), voucher.tokenId, voucher.Amount);
        NFT.setURI(voucher.tokenId, voucher.uri);
        //_transfer(signer, redeemer, voucher.tokenId);
        return voucher.tokenId;
    }

    function buy(
        address sender,
        uint256 tokenId,
        uint160 amount,
        SELLVoucher calldata voucher2
    ) external payable {
        require(!VOUCHERcount[voucher2.voucherCount], "already used voucher");
        address signer = _verify2(voucher2);
        // uint160 v2addr =  conversion(voucher2.)
        // console.log(v2addr, "this signer is from buy");
        console.log(
            NFT.balanceOf(sender, tokenId),
            "this is signer NFT balance"
        );

        require(NFT.balanceOf(sender, tokenId) > 0, " balance is not there");
        require(msg.value == price, "not equal");

        NFT.safeTransferFrom(sender, msg.sender, tokenId, amount, "");
        Royalty = (msg.value * OwnerRoyalty) / 100;
        value = Royalty / OwnerCount[tokenId];
        for (uint256 i = 0; i < OwnerCount[tokenId]; i++) {
            (bool sent, bytes memory data) = payable(
                (OwnerAddress[tokenId][i + 1])
            ).call{value: value}("");
            require(sent, "Failed to send  to Owner(royalty");
        }
        (bool sent, bytes memory data) = payable((sender)).call{
            value: (msg.value * (100 - OwnerRoyalty)) / 100
        }("");
        require(sent, "Failed to send  to seller");
        VOUCHERcount[voucher2.voucherCount] = true;
            console.log(
            NFT.balanceOf(sender, tokenId),
            "this is signer NFT balance"
        );
        emit transfer(sender, msg.sender, tokenId, amount, msg.value);
    }

    //     function check(exampleVoucher calldata voucher) public returns (uint256) {
    //     address signer = _verify3(voucher);
    //     require(voucher.Address == conversion(msg.sender) ,"unauthorized Access");
    //     console.log(signer ,"this signer from check");
    //     // require(hasRole(MINTER_ROLE, signer) , "Signature invalid or unauthorized");
    //     // OwnerCount[voucher.tokenId] ++;
    //     // OwnerAddress[voucher.tokenId][ OwnerCount[voucher.tokenId]] = address(voucher.Address);
    //     // NFT.mint(address(voucher.Address),voucher.tokenId,voucher.Amount);
    //     // NFT.setURI(voucher.tokenId,voucher.uri);
    //     // //_transfer(signer, redeemer, voucher.tokenId);
    //     // return voucher.tokenId;
    // }

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

    function setprice(uint256 _val) external onlyRole(DEFAULT_ADMIN_ROLE) {
        price = uint256(_val);
    }

    function setCreator(address _owner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Creator = _owner;
    }

    function setOwnerRoyalty(uint256 _val)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        OwnerRoyalty = uint256(_val);
    }
}
