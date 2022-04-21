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
    let owner: SignerWithAddress;
    let signers: SignerWithAddress[];

    beforeEach(async() => {
        signers = await ethers.getSigners();
        owner = signers[0];
        Contract = await new LazzyMinting__factory(owner).deploy(signers[1].address);
    });

    it("redeem : success", async() => {
        const lazyMinting = new LazyMinting({_contract:Contract, _signer:signers[1]});
        const voucher = await lazyMinting.createVoucher(1,await Contract.conversion(signers[1].address),100,"komal");
        await Contract.connect((signers[1])).redeem(signers[1].address,voucher);
    });

});

