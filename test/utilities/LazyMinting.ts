import { BigNumberish, BytesLike, ethers, Wallet } from "ethers"
import { formatBytes32String } from "ethers/lib/utils";
import { encode } from "querystring";
import { any } from "underscore";

const SIGNING_DOMAIN_NAME = "LazyNFT-Voucher"  // encode krne ke liye salt lgti hai  ex:-  adding formula  values alg dono ki 2 persons
const SIGNING_DOMAIN_VERSION = "1"  //  dono ko mila kr salt

/**
 * LazyMinter is a helper class that creates NFTVoucher objects and signs them, to be redeemed later by the LazyNFT contract.
 */
 class LazyMinter {

  public contract : any; 
  public signer : any; 
  public _domain : any;

  constructor(data:any) { 
    const {_contract, _signer} =data; 
    this.contract = _contract 
    this.signer = _signer
  }

  async createVoucher(tokenId: any, Address: any,Amount: any,uri: any) {
    const voucher = { tokenId, Address,Amount ,uri}
    const domain = await this._signingDomain()
    const types = {
      NFTVoucher: [
        {name: "tokenId", type: "uint256"},
        {name: "Address", type: "uint160"},
        {name: "Amount", type: "uint256"},
        {name: "uri", type: "string"}, 

      ]
    }
    const signature = await this.signer._signTypedData(domain, types, voucher)
    // console.log("signature",signature);
    // console.log(voucher,"voucher");
    return {
      ...voucher,
      signature,
    }
  }
  
  async sellVoucher(tokenId: any, Address: any, Amount: any, signer:any,uri: any ) {
    console.log("address",signer.address);
    const Voucher = { tokenId, Address,Amount, uri}
    const domain = await this._signingDomain()
    const types = {
      SELLVoucher: [
        {name: "tokenId", type: "uint256"},
        {name: "Address", type: "uint160"},
        {name: "Amount", type: "uint256"},
        {name: "uri", type: "string"}, 
      ]
    }
    // console.log("sign",signer);
    const signature = await signer._signTypedData(domain, types, Voucher)
    console.log("sign",signature);
    return{
      ...Voucher,
      signature,
    }
  }

  async _signingDomain() {
    if (this._domain != null) {
      return this._domain
    }
    const chainId = await this.contract.getChainID()
    this._domain  = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: this.contract.address,
      chainId,
    }
    return this._domain
  }
}

export default LazyMinter;
