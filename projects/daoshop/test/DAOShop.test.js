const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAOShop", function () {
    let daoShop;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        const DAOShop = await ethers.getContractFactory("DAOShop");
        daoShop = await DAOShop.deploy();
        await daoShop.deployed();
    });

    describe("商品の作成", function () {
        it("新しい商品を作成できる", async function () {
            const tx = await daoShop.connect(addr1).createItem(
                "テスト商品",
                "0x123/1",
                "test@example.com",
                "1000円",
                "販売中"
            );
            
            const receipt = await tx.wait();
            const event = receipt.events.find(event => event.event === "ItemCreated");
            
            expect(event).to.not.be.undefined;
            expect(event.args[2]).to.equal("テスト商品");
            
            const item = await daoShop.getItem(0);
            expect(item.title).to.equal("テスト商品");
            expect(item.creator).to.equal(addr1.address);
        });
    });

    describe("商品の更新", function () {
        beforeEach(async function () {
            await daoShop.connect(addr1).createItem(
                "テスト商品",
                "0x123/1",
                "test@example.com",
                "1000円",
                "販売中"
            );
        });

        it("作成者は商品を更新できる", async function () {
            await daoShop.connect(addr1).updateItem(
                0,
                "更新された商品",
                "0x456/2",
                "new@example.com",
                "2000円",
                "売切"
            );

            const item = await daoShop.getItem(0);
            expect(item.title).to.equal("更新された商品");
            expect(item.price).to.equal("2000円");
            expect(item.status).to.equal("売切");
        });

        it("作成者以外は商品を更新できない", async function () {
            await expect(
                daoShop.connect(addr2).updateItem(
                    0,
                    "不正な更新",
                    "0x789/3",
                    "hacker@example.com",
                    "0円",
                    "無料"
                )
            ).to.be.revertedWith("Only item creator can update");
        });
    });

    describe("商品の削除", function () {
        beforeEach(async function () {
            await daoShop.connect(addr1).createItem(
                "テスト商品",
                "0x123/1",
                "test@example.com",
                "1000円",
                "販売中"
            );
        });

        it("作成者は商品を削除できる", async function () {
            await daoShop.connect(addr1).burnItem(0);
            
            await expect(daoShop.getItem(0)).to.be.revertedWith("ERC721: invalid token ID");
        });

        it("作成者以外は商品を削除できない", async function () {
            await expect(
                daoShop.connect(addr2).burnItem(0)
            ).to.be.revertedWith("Only item creator can update");
        });
    });

    describe("NFTトークンの所有権", function () {
        it("商品作成時にNFTが発行される", async function () {
            await daoShop.connect(addr1).createItem(
                "テスト商品",
                "0x123/1",
                "test@example.com",
                "1000円",
                "販売中"
            );

            expect(await daoShop.ownerOf(0)).to.equal(addr1.address);
            expect(await daoShop.balanceOf(addr1.address)).to.equal(1);
        });
    });
});