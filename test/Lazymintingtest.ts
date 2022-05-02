import{ 
    LazzyMinting,
    LazzyMinting__factory,
    NFT1155,
    NFT1155__factory
}
from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers ,waffle} from "hardhat";
import { mineBlocks, expandTo18Decimals } from "./utilities/utilities";
import { expect } from "chai";
import LazyMinting from "./utilities/LazyMinting";
// import LazyMinting2 from "./utilities/Lazyminiting2";
const provider = waffle.provider;

describe("LazyMinting", async() => {
    let Contract: LazzyMinting;
    let  nft : NFT1155 ;
    let owner: SignerWithAddress;
    let signers: SignerWithAddress[];

    beforeEach(async() => {
        signers = await ethers.getSigners();
        owner = signers[1];
        nft = await new NFT1155__factory(owner).deploy();
        Contract = await new LazzyMinting__factory(owner).deploy(signers[1].address,nft.address);
        console.log(owner.address,"owner Address");
        console.log(nft.address,"nft deployed Address");
        console.log(Contract.address,"owner deployed Address");

        // let role = await nft.connect(owner).MINTER_ROLE();
        // console.log(role);
        await nft.connect(owner).setMinter(Contract.address);
       // console.log("owner", await nft.hasRole(await nft.MINTER_ROLE(),Contract.address));
    });

    it.only("redeem : success", async() => {
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});

        console.log(signers[1].address);
        const balanceInWei = await provider.getBalance(signers[1].address);
        console.log(ethers.utils.formatEther(balanceInWei) ,"signers[1].address balance");

        const balanceInWei2 = await provider.getBalance(signers[2].address);
        console.log(ethers.utils.formatEther(balanceInWei2) ,"signers[2].address balance");

        const balanceInWei2contract= await provider.getBalance(Contract.address);
        console.log(ethers.utils.formatEther(balanceInWei2contract) ,"Contract.address balance");
        
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[2].address),100,expandTo18Decimals(1),"komal");
        console.log("voucher");
        const call= await Contract.connect(signers[2]).redeem(voucher,{value:expandTo18Decimals(1)});
     
        const balanceInWeiafter = await provider.getBalance(signers[1].address);
        console.log(ethers.utils.formatEther(balanceInWeiafter) ,"signers[1].address balance After");

        const balanceInWei2after = await provider.getBalance(signers[2].address);
        console.log(ethers.utils.formatEther(balanceInWei2after) ,"signers[2].address balance After");
        // console.log(call);

        const balanceInWei2contractafter= await provider.getBalance(Contract.address);
        console.log(ethers.utils.formatEther(balanceInWei2contractafter) ,"Contract.address balance  After");
        const AmountNFT = await nft.balanceOf(signers[2].address ,1);
        console.log(Number(AmountNFT), "AMOuntNFT");
   
        expect(Number(AmountNFT)).to.be.eq(Number(100));
    });
    // it("redeem : success", async() => {
    //     const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
    //     console.log(signers[1].address);
    //     const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[2].address),100,"komal");
    //     // console.log(voucher,"voucher");
    //     await Contract.connect(signers[2]).redeem(voucher);
    //     const AmountNFT = await nft.balanceOf(signers[2].address ,1);
    //     console.log(Number(AmountNFT), "AMOuntNFT");
   
    //     expect(Number(AmountNFT)).to.be.eq(Number(100));
    // });

    it("redeem : Reverted", async() => {
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
        //console.log(signers[1]);
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[1].address),100,expandTo18Decimals(1),"komal");
        // await Contract.connect(signers[2]).redeem(voucher);
        const AmountNFT = await nft.balanceOf(signers[2].address ,1);
        console.log(Number(AmountNFT), "AMOuntNFT");
  
        await expect(Contract.connect(signers[2]).redeem(voucher)).to.be.revertedWith("unauthorized Access");
    });
                                                                                                                                                                                                                                                                                                                                                                                                            
    it("buy" , async () => {
        console.log(signers[1].address,"address 1");
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[2].address),100,expandTo18Decimals(1),"komal");
        await Contract.connect(signers[2]).redeem(voucher);
        const AmountNFT = await nft.balanceOf(signers[2].address ,1);
        console.log(Number(AmountNFT), "AMOuntNFT in buy case");
        await Contract.connect(signers[1]).setprice(expandTo18Decimals(1));

        const lazyMinting1 = new LazyMinting({_contract:Contract, _signer:signers[2]});

        const Voucher = await lazyMinting1.sellVoucher(1,signers[2],await Contract.conversion(signers[2].address),1,"komal");

        // console.log(Voucher,"this is the sell siganture voucher test");
        console.log(signers[2].address,"this is the second addr for buy");
        console.log(signers[3].address,"this is the 3 addr for buy")

        // await nft.connect(signers[2]).setApprovalForAll(Contract.address,true);
        await nft.connect(signers[2]).setApprovalForAll(signers[3].address,true);

        await Contract.connect(signers[3]).buy(signers[2].address,1, 7,Voucher,{value: expandTo18Decimals(1)});
        
        const AmountNFT1 = await nft.balanceOf(signers[3].address ,1);
        console.log(Number(AmountNFT1), "AMOuntNFT1");
        // await Contract.connect(signers[1]).setApprovalForAll(signers[1].address,true);
        // await Contract.connect((signers[1])).buy(signers[2].address, 1, 100);
    });
///////////////////////////////////////////////////
    // it.only("redeem : check", async() => {
    //     const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
    //     console.log(signers[1].address ,"this is addr 1");
    //     console.log(signers[2].address ,"this is addr 2");

    //     const voucher = await lazyMinting.checkVoucher(1,signers[2],await Contract.conversion(signers[2].address),100,"komal");
    //     // console.log(voucher,"voucher");
    //      await Contract.connect(signers[2]).check(voucher);
    //     // const AmountNFT = await nft.balanceOf(signers[2].address ,1);
    //     // console.log(Number(AmountNFT), "AMOuntNFT");
   
    //     // expect(Number(AmountNFT)).to.be.eq(Number(100));
    // });

});

