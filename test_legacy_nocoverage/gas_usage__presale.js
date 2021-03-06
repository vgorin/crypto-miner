const ROLE_TOKEN_CREATOR = 0x00040000;
const ROLE_ROLE_MANAGER = 0x10000000;

const Token = artifacts.require("./GemERC721");
const Sale = artifacts.require("./CouponSale");

contract('GeodeSale: Gas Usage', function(accounts) {
	it("gas: deploying a GemERC721 requires 3585837 gas", async() => {
		const token = await Token.new();
		const txHash = token.transactionHash;
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);
		const gasUsed = txReceipt.gasUsed;

		assertEqual(3585837, gasUsed, "deploying a GemERC721 gas usage mismatch: " + gasUsed);
	});

	it("gas: deploying a geode sale requires 2638285 gas", async() => {
		const token = await Token.new();
		const sale = await Sale.new(token.address, accounts[9], accounts[9]);
		const txHash = sale.transactionHash;
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);
		const gasUsed = txReceipt.gasUsed;

		assertEqual(2638285, gasUsed, "deploying a geode sale gas usage mismatch: " + gasUsed);
	});

	it("gas: buying a geode requires 572310 gas", async() => {
		const token = await Token.new();
		const sale = await Sale.new(token.address, accounts[9], accounts[9]);

		await token.updateFeatures(ROLE_ROLE_MANAGER | ROLE_TOKEN_CREATOR);
		await token.addOperator(sale.address, ROLE_TOKEN_CREATOR);
		const txHash = await sale.getGeodes.sendTransaction({value: await sale.currentPrice()});
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);
		const gasUsed = txReceipt.gasUsed;

		assertEqual(572310, gasUsed, "buying a geode gas usage mismatch: " + gasUsed);
	});

	it("gas: buying 10 geodes requires 5155634 gas", async() => {
		const token = await Token.new();
		const sale = await Sale.new(token.address, accounts[9], accounts[9]);

		await token.updateFeatures(ROLE_ROLE_MANAGER | ROLE_TOKEN_CREATOR);
		await token.addOperator(sale.address, ROLE_TOKEN_CREATOR);
		const txHash = await sale.getGeodes.sendTransaction({value: (await sale.currentPrice()).times(10)});
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);
		const gasUsed = txReceipt.gasUsed;

		assertEqual(5155634, gasUsed, "buying a geode gas usage mismatch: " + gasUsed);
	});
});


// asserts equal with precision of 5%
function assertEqual(expected, actual, msg) {
	assertEqualWith(expected, 0.05, actual, msg);
}

// asserts equal with the precisions defined in leeway
function assertEqualWith(expected, leeway, actual, msg) {
	assert(expected * (1 - leeway) < actual && expected * (1 + leeway) > actual, msg);
}
