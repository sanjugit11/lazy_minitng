// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "contracts/ERC1155/1155.sol";
import "contracts/I1155.sol";
import "contracts/ERC1155/IERC1155.sol";
import "hardhat/console.sol";

contract LazzyMinting is AccessControl,EIP712("LazyNFT-Voucher", "1"){

    //setcreator public creator;
    uint public price;
    uint public Royalty;
    uint public value;
    //uint public OwnerRoyalty;
    address public Creator;

    I1155 public NFT;


    mapping(uint => uint) public OwnerCount;   // function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl,ERC1155) returns (bool){
    //    super.supportsInterface(interfaceId);
    // }
    mapping(uint => mapping(uint => address)) public OwnerAddress;

    event transfer ( address from, address to ,uint tokenId,  uint tokenamount, uint amount );

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "LazyNFT-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    constructor (address payable minter, address _NFT)
    {
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
 
    function _hash(NFTVoucher calldata voucher) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        
                        keccak256(
                            "NFTVoucher(uint256 tokenId,uint160 Address,uint160 Amount,string uri)"
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
        return ECDSA.recover(digest,voucher.signature);
    }

    function redeem(address redeemer, NFTVoucher calldata voucher) public returns (uint256) {
        address signer = _verify(voucher);
        require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");
        OwnerCount[voucher.tokenId] ++; 
        OwnerAddress[voucher.tokenId][ OwnerCount[voucher.tokenId]] = address(voucher.Address);
        NFT.mint(address(voucher.Address),voucher.tokenId,voucher.Amount);
        NFT.setURI(voucher.tokenId,voucher.uri);
        //_transfer(signer, redeemer, voucher.tokenId);
        return voucher.tokenId;
    }
                                                                                                                                                                            
    function buy(address sender,uint256 tokenId,uint160 amount,bytes memory data) payable external {
       require(msg.value == price, "not equal");
       console.log(sender, address(this));
       //console.log("approve", isApprovedForAll(sender, address(this)), balanceOf(sender,tokenId));
       NFT.safeTransferFrom(sender,msg.sender,tokenId,amount,data);
        Royalty = msg.value * 5/100;
        value = Royalty / OwnerCount[tokenId];
       for(uint i = 0; i < OwnerCount[tokenId]; i++){
            (bool sent, bytes memory data) = payable((OwnerAddress[tokenId][i+1])).call{value: value}("");
            require(sent, "Failed to send  to Owner(royalty");
        }
            (bool sent, bytes memory data) = payable((sender)).call{value: msg.value * 95/100}("");
            require(sent, "Failed to send  to seller");

    emit transfer(sender,msg.sender,tokenId,amount,msg.value );
    }

    // function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl,ERC1155) returns (bool){
    //    super.supportsInterface(interfaceId);
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

    function setprice(uint _val) external onlyRole(DEFAULT_ADMIN_ROLE){
        price = uint(_val);
    }

    function setCreator(address _owner) external onlyRole(DEFAULT_ADMIN_ROLE){
        Creator = _owner;
    }

    // function setOwnerRoyalty(uint _val) external onlyRole(DEFAULT_ADMIN_ROLE){
    //      OwnerRoyalty = uint(_val);
    // }

    // function setHoldersRoyalty(uint _val) external onlyRole(DEFAULT_ADMIN_ROLE){
    //      OwnerRoyalty = uint(_val);
    // }

}