// smart contract to test gas usage for
const Token = artifacts.require("./GemERC721.sol");

// import features and roles required
import {FEATURE_TRANSFERS} from "../test/erc721_core";

// gas usage tests
contract('GemERC721: Gas Usage', (accounts) => {
	it("gas: deploying GemERC721 requires 5,210,792 gas", async() => {
		const tk = await Token.new();
		const txHash = tk.transactionHash;
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);
		const gasUsed = txReceipt.gasUsed;

		assertEqual(5210792, gasUsed, "deploying GemERC721 gas usage mismatch: " + gasUsed);
	});

	it("gas: minting a token requires 216,226 gas", async() => {
		const tk = await Token.new();
		const gasUsed = (await tk.mint(accounts[1], 1, 1, 1, 1, 0x1000001)).receipt.gasUsed;

		assertEqual(216226, gasUsed, "minting a token usage mismatch: " + gasUsed);
	});

	it("gas: leveling up a gem requires 31,744 gas", async() => {
		const tk = await Token.new();
		await tk.mint(accounts[1], 1, 1, 1, 1, 0x1000001);
		const gasUsed = (await tk.levelUpBy(1, 1)).receipt.gasUsed;

		assertEqual(31744, gasUsed, "leveling up a gem gas usage mismatch: " + gasUsed);
	});

	it("gas: upgrading a gem requires 31,803 gas", async() => {
		const tk = await Token.new();
		await tk.mint(accounts[1], 1, 1, 1, 1, 0x1000001);
		const gasUsed = (await tk.upgrade(1, 0x1000002)).receipt.gasUsed;

		assertEqual(31803, gasUsed, "upgrading a gem gas usage mismatch: " + gasUsed);
	});

	it("gas: setting energetic age of a gem requires 31,651 gas", async() => {
		const tk = await Token.new();
		await tk.mint(accounts[1], 1, 1, 1, 1, 0x1000001);
		const gasUsed = (await tk.setAge(1, 1)).receipt.gasUsed;

		assertEqual(31651, gasUsed, "updating energetic age of a gem gas usage mismatch: " + gasUsed);
	});

	it("gas: updating gem state requires 31,727 gas", async() => {
		const tk = await Token.new();
		await tk.mint(accounts[1], 1, 1, 1, 1, 0x1000001);
		const gasUsed = (await tk.setState(1, 1)).receipt.gasUsed;

		assertEqual(31727, gasUsed, "updating gem state gas usage mismatch: " + gasUsed);
	});

	it("gas: transferring a token requires 70,274 gas", async() => {
		const player = accounts[1];
		const player2 = accounts[2];
		const tk = await Token.new();
		await tk.updateFeatures(FEATURE_TRANSFERS);
		await tk.mint(player, 1, 1, 1, 1, 0x1000001);
		const gasUsed = (await tk.safeTransferFrom(player, player2, 1, {from: player})).receipt.gasUsed;

		assertEqual(70274, gasUsed, "transferring a token gas usage mismatch: " + gasUsed);
	});

});

// asserts equal with precision of 5%
function assertEqual(expected, actual, msg) {
	assertEqualWith(expected, actual, 0.05, msg);
}

// asserts equal with the precisions defined in leeway
function assertEqualWith(expected, actual, leeway, msg) {
	assert(expected * (1 - leeway) < actual && expected * (1 + leeway) > actual, msg);
}