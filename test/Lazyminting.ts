import{ 
    LazzyMinting,
    LazzyMinting__factory,
}
from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { mineBlocks, expandTo18Decimals } from "./utilities/utilities";
import { expect } from "chai";
import LazyMinting from "./utilities/LazyMinting";

describe("LazyMinting", async() => {
    let Contract: LazzyMinting;
    //let contract : erc1155 ;
    let owner: SignerWithAddress;
    let signers: SignerWithAddress[];

    beforeEach(async() => {
        signers = await ethers.getSigners();
        owner = signers[1];
        Contract = await new LazzyMinting__factory(owner).deploy(signers[1].address,signers[2].address);
        //contract = await new erc1155__factory(owner).deploy(signers[2].address);
    });

    it("redeem : success", async() => {
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
        console.log(signers[1]);
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[1].address),100,"komal");
        await Contract.connect((signers[1])).redeem(signers[1].address,voucher);
        const AmountNFT = await Contract.balanceOf(signers[0].address ,1);
        console.log(Number(AmountNFT), "AMOuntNFT");
        const AmountNFT1 = await Contract.balanceOf(signers[1].address ,1);
        console.log(Number(AmountNFT1), "AMOuntNFT1");
        // expect(await Contract.balanceOf(signers[1].address))
    });

    it("redeem : success", async() => {
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
        // console.log(signers[1]);
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[2].address),100,"komal");
        await Contract.connect((signers[2])).redeem(signers[2].address,voucher);
        const AmountNFT = await Contract.balanceOf(signers[0].address ,1);
        console.log(Number(AmountNFT), "AMOuntNFT");
        const AmountNFT1 = await Contract.balanceOf(signers[2].address ,1);
        console.log(Number(AmountNFT1), "AMOuntNFT1");
        // expect(await Contract.balanceOf(signers[1].address))
    });
                                                                                                                                                                                                                                                                                                                                                                                                            
    it("buy" , async () => {
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[1].address),100,"komal");
        await Contract.connect((signers[1])).redeem(signers[1].address,voucher);
        await Contract.connect(signers[1]).setprice(expandTo18Decimals(1));
        await Contract.connect(signers[1]).setApprovalForAll(Contract.address,true);
        await Contract.connect(signers[2]).buy(signers[1].address, 1, 10,{value: expandTo18Decimals(1)});
        const AmountNFT1 = await Contract.balanceOf(signers[2].address ,1);
        console.log(Number(AmountNFT1), "AMOuntNFT1");
        // await Contract.connect(signers[1]).setApprovalForAll(signers[1].address,true);
        // await Contract.connect((signers[1])).buy(signers[2].address, 1, 100);
    });

});

