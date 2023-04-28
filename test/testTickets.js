const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TicketSale", function () {
  let SimpleToken;
  let simpleToken;
  let owner;
  let user1;
  let user2;
  let user3;
  let addrs;

  beforeEach(async function () {
    [owner, user1, user2, user3, ...addrs] = await ethers.getSigners();

    SimpleToken = await ethers.getContractFactory("TicketSale");
    simpleToken = await SimpleToken.connect(owner).deploy();
    await simpleToken.deployed();
  });

  describe("Mint", function () {
    it("Admin can't request refund before the end of the event", async function () {
      const eventDate = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 7; // Event date set to 1 week from now
      await simpleToken.connect(owner).setEventDate(eventDate);

      const initialBalance = await ethers.provider.getBalance(owner.address);
      await expect(simpleToken.connect(owner).requestRefund()).to.be.revertedWith("Event is not over yet");
      expect(await ethers.provider.getBalance(owner.address)).to.equal(initialBalance);
    });

    it("User can't buy more than 4 tickets", async function () {
      const ticketPrice = await simpleToken.ticketPrice();
      const maxTicketsPerUser = await simpleToken.maxUserTickets();

      // User1 buys 4 tickets
      await simpleToken.connect(user1).buyTickets(4);
      expect(await simpleToken.ticketsBought(user1.address)).to.equal(4);

      // User1 tries to buy another ticket and fails
      await expect(simpleToken.connect(user1).buyTickets(1)).to.be.revertedWith("You can't buy more tickets");
      expect(await simpleToken.ticketsBought(user1.address)).to.equal(4);

      // User2 tries to buy 5 tickets and fails
      await expect(simpleToken.connect(user2).buyTickets(5)).to.be.revertedWith("You can't buy more tickets");
      expect(await simpleToken.ticketsBought(user2.address)).to.equal(0);
    });

    it("User can cancel and get a refund", async function () {
      const ticketPrice = await simpleToken.ticketPrice();

      // User1 buys a ticket
      await simpleToken.connect(user1).buyTickets(1);
      expect(await simpleToken.ticketsBought(user1.address)).to.equal(1);

      // User1 cancels and gets a refund
      const initialBalance = await ethers.provider.getBalance(user1.address);
      await simpleToken.connect(user1).cancelTicket();
      expect(await simpleToken.ticketsBought(user1.address)).to.equal(0);
      expect(await ethers.provider.getBalance(user1.address)).to.be.above(initialBalance);
    });
  });
});
