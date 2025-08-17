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
                "これはテスト商品の説明です",
                "https://example.com/image.jpg",
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
                "これはテスト商品の説明です",
                "https://example.com/image.jpg",
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
                "更新された商品の説明",
                "https://example.com/updated.jpg",
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
                    "不正な説明",
                    "https://example.com/hack.jpg",
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
                "これはテスト商品の説明です",
                "https://example.com/image.jpg",
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
                "これはテスト商品の説明です",
                "https://example.com/image.jpg",
                "0x123/1",
                "test@example.com",
                "1000円",
                "販売中"
            );

            expect(await daoShop.ownerOf(0)).to.equal(addr1.address);
            expect(await daoShop.balanceOf(addr1.address)).to.equal(1);
        });
    });

    describe("tokenURIメタデータ", function () {
        beforeEach(async function () {
            await daoShop.connect(addr1).createItem(
                "テスト商品",
                "これはテスト商品の説明です",
                "https://example.com/image.jpg",
                "0x123/1",
                "test@example.com",
                "1000円",
                "販売中"
            );
        });

        it("正しいメタデータを返す", async function () {
            const uri = await daoShop.tokenURI(0);
            expect(uri).to.include("data:application/json;base64,");
            
            // Base64デコードしてJSONを検証
            const base64 = uri.split("data:application/json;base64,")[1];
            const json = JSON.parse(Buffer.from(base64, 'base64').toString());
            
            expect(json.name).to.equal("テスト商品");
            expect(json.description).to.equal("これはテスト商品の説明です");
            expect(json.image).to.equal("https://example.com/image.jpg");
            expect(json.attributes).to.have.lengthOf(4);
            expect(json.attributes[0].trait_type).to.equal("Price");
            expect(json.attributes[0].value).to.equal("1000円");
        });
    });

    describe("Enumeration機能", function () {
        beforeEach(async function () {
            // addr1が2つ、addr2が1つ商品を作成
            await daoShop.connect(addr1).createItem(
                "商品1", "説明1", "https://example.com/1.jpg",
                "0x123/1", "test1@example.com", "1000円", "販売中"
            );
            await daoShop.connect(addr1).createItem(
                "商品2", "説明2", "https://example.com/2.jpg",
                "0x123/2", "test2@example.com", "2000円", "販売中"
            );
            await daoShop.connect(addr2).createItem(
                "商品3", "説明3", "https://example.com/3.jpg",
                "0x123/3", "test3@example.com", "3000円", "販売中"
            );
        });

        it("総供給量を取得できる", async function () {
            expect(await daoShop.totalSupply()).to.equal(3);
        });

        it("インデックスでトークンIDを取得できる", async function () {
            expect(await daoShop.tokenByIndex(0)).to.equal(0);
            expect(await daoShop.tokenByIndex(1)).to.equal(1);
            expect(await daoShop.tokenByIndex(2)).to.equal(2);
        });

        it("所有者別のトークンを取得できる", async function () {
            expect(await daoShop.balanceOf(addr1.address)).to.equal(2);
            expect(await daoShop.tokenOfOwnerByIndex(addr1.address, 0)).to.equal(0);
            expect(await daoShop.tokenOfOwnerByIndex(addr1.address, 1)).to.equal(1);
            
            expect(await daoShop.balanceOf(addr2.address)).to.equal(1);
            expect(await daoShop.tokenOfOwnerByIndex(addr2.address, 0)).to.equal(2);
        });

        it("作成者別のトークンを取得できる", async function () {
            expect(await daoShop.creatorTokenCount(addr1.address)).to.equal(2);
            expect(await daoShop.creatorTokenCount(addr2.address)).to.equal(1);
            
            const addr1Tokens = await daoShop.getCreatorTokens(addr1.address);
            expect(addr1Tokens.map(t => t.toNumber())).to.deep.equal([0, 1]);
            
            const addr2Tokens = await daoShop.getCreatorTokens(addr2.address);
            expect(addr2Tokens.map(t => t.toNumber())).to.deep.equal([2]);
        });

        it("削除後も正しくEnumerationが機能する", async function () {
            await daoShop.connect(addr1).burnItem(1);
            
            expect(await daoShop.totalSupply()).to.equal(2);
            expect(await daoShop.creatorTokenCount(addr1.address)).to.equal(1);
            
            const addr1Tokens = await daoShop.getCreatorTokens(addr1.address);
            expect(addr1Tokens.map(t => t.toNumber())).to.deep.equal([0]);
        });
    });
});