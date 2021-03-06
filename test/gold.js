// GoldERC20 smart contract
const Token = artifacts.require("./GoldERC20.sol");
// Dummy ERC20/ERC721 Receiver
const Receiver = artifacts.require("./__DummyReceiver.sol");

// import ERC721Core dependencies
import {
	// Enables ERC20 transfers of the tokens
	FEATURE_TRANSFERS,
	// Enables ERC20 transfers on behalf
	FEATURE_TRANSFERS_ON_BEHALF,
	ROLE_TOKEN_CREATOR,
	ROLE_TOKEN_DESTROYER
} from "./erc721_core";

// tests for GoldERC20 token
contract('GoldERC20', (accounts) => {

	it("deployment: initial token state", async() => {
		const tk = await Token.new();
		const account0 = accounts[0];
		assert.equal("GLD", await tk.symbol(), "wrong token symbol");
		assert.equal(3, await tk.decimals(), "wrong token decimals");
		assert.equal(0, await tk.totalSupply(), "non-zero initial value for totalSupply()");
		assert.equal(0, await tk.balanceOf(account0), "non-zero initial value for balanceOf(account0)");
		assert.equal(0, await tk.allowance(account0, accounts[1]), "non-zero initial value for allowance(account0, account1)");
	});

	it("permissions: creator and destroyer are different permissions", async() => {
		assert(ROLE_TOKEN_CREATOR !== ROLE_TOKEN_DESTROYER, "creator and destroyer permissions are equal");
	});
	it("permissions: minting tokens requires ROLE_TOKEN_CREATOR permission", async() => {
		const tk = await Token.new();

		// token creator
		const creator = accounts[1];

		// player
		const player = accounts[2];

		// function to mint tokens
		const fn = async() => await tk.mintNative(player, 1, {from: creator});

		// originally creator doesn't have required permission
		await assertThrows(fn);

		// grant creator permission required
		await tk.updateRole(creator, ROLE_TOKEN_CREATOR);

		// verify creator can perform an operation now
		await fn();

		// verify tokens increased correctly
		assert.equal(1, await tk.balanceOf(player), "incorrect token balance after minting a token");
	});
	it("permissions: burning tokens requires ROLE_TOKEN_DESTROYER permission", async() => {
		const tk = await Token.new();

		// token destroyer
		const destroyer = accounts[1];

		// player
		const player = accounts[2];

		// function to burn tokens
		const fn = async() => await tk.burn(player, 1, {from: destroyer});

		// mint a token to be burnt first
		await tk.mint(player, 1);

		// originally destroyer doesn't have required permission
		await assertThrows(fn);

		// grant destroyer permission required
		await tk.updateRole(destroyer, ROLE_TOKEN_DESTROYER);

		// verify destroyer can perform an operation now
		await fn();

		// verify tokens decreased correctly
		assert.equal(0, await tk.balanceOf(player), "incorrect token balance after burning a token");
	});
	it("permissions: transfers and transfers on behalf are different features", async() => {
		assert(FEATURE_TRANSFERS !== FEATURE_TRANSFERS_ON_BEHALF, "transfers and transfers on behalf features are equal");
	});
	it("permissions: transfers require FEATURE_TRANSFERS feature to be enabled", async() => {
		const tk = await Token.new();

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// mint some tokens
		const amt = rnd();
		await tk.mintNative(player1, amt);

		// transfer functions
		const fn1 = async() => await tk.transfer(player2, amt, {from: player1});
		const fn2 = async() => await tk.transfer(player1, amt, {from: player2});
		const fn1f = async() => await tk.transferFrom(player1, player2, amt, {from: player1});
		const fn2f = async() => await tk.transferFrom(player2, player1, amt, {from: player2});

		// transfers don't work without feature required
		await assertThrows(fn1);
		await assertThrows(fn2);
		await assertThrows(fn1f);
		await assertThrows(fn2f);

		// enable feature required
		await tk.updateFeatures(FEATURE_TRANSFERS);

		// perform the transfers
		await fn1();
		await fn2();
		await fn1f();
		await fn2f();

		// verify token balances
		assert.equal(amt, await tk.balanceOf(player1), "wrong player 1 balance after several transfers");
		assert.equal(0, await tk.balanceOf(player2), "non-zero player 2 balance after several transfers");
	});
	it("permissions: transfers on behalf require FEATURE_TRANSFERS_ON_BEHALF feature to be enabled", async() => {
		const tk = await Token.new();

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// exchange (account granted to transfer on behalf)
		const exchange = accounts[3];

		// mint some tokens
		const amt = rnd();
		await tk.mintNative(player1, amt);

		// grant an exchange permissions to perform transfers on behalf
		await tk.approve(exchange, amt * 10, {from: player1});
		await tk.approve(exchange, amt * 10, {from: player2});

		// transfer on behalf functions
		const fn = async() => await tk.transferFrom(player1, player2, amt, {from: exchange});

		// transfer on behalf doesn't work without feature required
		await assertThrows(fn);

		// enable feature required
		await tk.updateFeatures(FEATURE_TRANSFERS_ON_BEHALF);

		// perform the transfer on behalf
		await fn();

		// verify token balances
		assert.equal(0, await tk.balanceOf(player1), "non-zero player 1 balance after several transfers");
		assert.equal(amt, await tk.balanceOf(player2), "wrong player 2 balance after several transfers");
	});

	it("minting and burning: minting, burning, zero-value checks", async() => {
		const tk = await Token.new();

		// token creator
		const creator = accounts[1];

		// token destroyer
		const destroyer = accounts[2];

		// player (address to mint tokens to)
		const player = accounts[3];

		// some random amount of tokens
		const amt = rnd();

		// functions to mint and burn tokens
		const mintTo = async(to, amt) => await tk.mintNative(to, amt, {from: creator});
		const mint = async() => await mintTo(player, amt);
		const burnFrom = async(from, amt) => await tk.burnNative(from, amt, {from: destroyer});
		const burn = async() => await burnFrom(player, amt);

		// initial token balance is zero
		assert.equal(0, await tk.balanceOf(player), "non-zero initial player balance");

		// grant creator and destroyer permission required
		await tk.updateRole(creator, ROLE_TOKEN_CREATOR);
		await tk.updateRole(destroyer, ROLE_TOKEN_DESTROYER);

		// burn cannot be called initially since there is not enough tokens to burn
		await assertThrows(burn);

		// mint some tokens
		await mint();

		// impossible to mint to zero address
		await assertThrows(mintTo, 0, amt);

		// impossible to mint zero value
		await assertThrows(mintTo, player, 0);

		// verify token balance
		assert.equal(amt, await tk.balanceOf(player), "incorrect token balance after minting some tokens");

		// verify total supply
		assert.equal(amt, await tk.totalSupply(), "incorrect total supply after minting some tokens");

		// impossible to burn zero value
		await assertThrows(burnFrom, player, 0);

		// burning is possible now: there is enough tokens to burn
		await burn();

		// verify token balance
		assert.equal(0, await tk.balanceOf(player), "incorrect token balance after burning the tokens");

		// verify total supply
		assert.equal(0, await tk.totalSupply(), "incorrect total supply after burning some tokens");

		// burning cannot be called now again
		await assertThrows(burn);
	});
	it("minting: arithmetic overflow check", async() => {
		const tk = await Token.new();

		// token creator
		const creator = accounts[1];

		// token destroyer
		const destroyer = accounts[2];

		// players (addresses to mint tokens to)
		const player1 = accounts[3];
		const player2 = accounts[4];

		// functions to mint tokens
		const mint0 = async() => await tk.mint(player1, big_max);
		const mint1 = async() => await tk.mintNative(player1, big_max);
		const mint2 = async() => await tk.mintNative(player2, big_max);

		// functions to burn tokens
		const burn0 = async() => await tk.burn(player1, big_max);
		const burn1 = async() => await tk.burnNative(player1, big_max);
		const burn2 = async() => await tk.burnNative(player2, big_max);

		// grant creator and destroyer permission required
		await tk.updateRole(creator, ROLE_TOKEN_CREATOR);
		await tk.updateRole(destroyer, ROLE_TOKEN_DESTROYER);

		// mint0 always overflows
		await assertThrows(mint0);
		// mint maximum value of tokens
		await mint1();
		// impossible to mint more tokens to the same player:
		await assertThrows(mint1);
		// impossible to mint more tokens to any other player:
		await assertThrows(mint2);

		// burn0 always overflows
		await assertThrows(burn0);
		// burn the tokens
		await burn1();
		// now we can mint them to some other player
		await mint2();
		// but we cannot mint them to first player anymore - overflow
		await assertThrows(mint1);

		// after burning the tokens
		await burn2();

		// total supply is zero again
		assert.equal(0, await tk.totalSupply(), "non-zero total supply after burning all the tokens");
	});

	it("transfers: transferring tokens", async() => {
		const tk = await Token.new();

		// enable feature: transfers (required)
		await tk.updateFeatures(FEATURE_TRANSFERS);

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// mint some tokens
		const amt = rnd();
		await tk.mintNative(player1, amt);

		// transfer functions: player1 -> player2 and player2 -> player1
		const fn1 = async() => await tk.transfer(player2, amt, {from: player1});
		const fn2 = async() => await tk.transfer(player1, amt, {from: player2});

		// perform the transfers, incorrect and correct, check balances after each transfer:
		// player 1 -> player 2
		await assertThrows(fn2);
		await fn1();
		assert.equal(0, await tk.balanceOf(player1), "non-zero player 1 balance");
		assert.equal(amt, await tk.balanceOf(player2), "wrong player 2 balance");

		// player 2 -> player 1
		await assertThrows(fn1);
		await fn2();
		assert.equal(0, await tk.balanceOf(player2), "non-zero player 2 balance");
		assert.equal(amt, await tk.balanceOf(player1), "wrong player 1 balance");

		// player 1 -> player 2 again
		await assertThrows(fn2);
		await fn1();
		assert.equal(0, await tk.balanceOf(player1), "non-zero player 1 balance (1)");
		assert.equal(amt, await tk.balanceOf(player2), "wrong player 2 balance (1)");
	});
	it("transfers: transferring on behalf", async() => {
		const tk = await Token.new();

		// enable feature: transfers on behalf (required)
		await tk.updateFeatures(FEATURE_TRANSFERS_ON_BEHALF);

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// exchange (account granted to transfer on behalf)
		const exchange = accounts[3];

		// mint some tokens
		const amt = rnd();
		await tk.mintNative(player1, amt);

		// transfer functions: player1 -> player2 and player2 -> player1
		const t1 = async() => await tk.transferFrom(player1, player2, amt, {from: exchange});
		const t2 = async() => await tk.transferFrom(player2, player1, amt, {from: exchange});

		// transfer approve on behalf functions:
		const ap1 = async() => await tk.approve(exchange, amt, {from: player1});
		const ap2 = async() => await tk.approve(exchange, amt, {from: player2});

		// perform the transfers, incorrect and correct, check balances after each transfer:
		// player 1 -> player 2
		await assertThrows(t1); // not approved
		await assertThrows(t2); // zero balance
		await ap1(); // approve
		await t1();  // transfer
		assert.equal(0, await tk.balanceOf(player1), "non-zero player 1 balance");
		assert.equal(amt, await tk.balanceOf(player2), "wrong player 2 balance");

		// player 2 -> player 1
		await assertThrows(t1); // zero balance
		await assertThrows(t2); // not approved
		await ap2(); // approve
		await t2();  // transfer
		assert.equal(0, await tk.balanceOf(player2), "non-zero player 2 balance");
		assert.equal(amt, await tk.balanceOf(player1), "wrong player 1 balance");
	});

	it("transfers: safe and unsafe transfers", async() => {
		// we will be using gold as a main token to operate with
		const tk = await Token.new();
		// silver as an unsafe smart contract which doesn't support ERC20Receiver
		const unsafeSc = (await Token.new()).address;
		// dummy receiver as a safe receiver
		const safeSc = (await Receiver.new()).address;

		// enable feature: transfers (required)
		await tk.updateFeatures(FEATURE_TRANSFERS);

		// define some player accounts
		const player1 = accounts[1];
		const player2 = accounts[2];

		// mint some tokens to the player
		await tk.mintNative(player1, 20);

		// define functions
		const safe = async(to) => await tk.transfer(to, 1, {from: player1});
		const safe2 = async(to) => await tk.transfer(to, 2, {from: player1});
		const unsafe = async(to) => await tk.unsafeTransferFrom(player1, to, 1, {from: player1});
		const unsafe2 = async(to) => await tk.unsafeTransferFrom(player1, to, 2, {from: player1});

		// both safe and unsafe transfers work with external addresses:
		await safe(player2);
		await safe2(player2);
		await unsafe(player2);
		await unsafe2(player2);

		// both safe and unsafe transfers work with safe smart contract -
		// if value is odd
		await safe(safeSc);
		await unsafe(safeSc);
		// but safe transfer fails if value is even
		await assertThrows(safe2, safeSc);
		// while unsafe does not
		await unsafe2(safeSc);

		// safe transfer fails with unsafe address
		await assertThrows(safe, unsafeSc);
		await assertThrows(safe2, unsafeSc);
		// while unsafe transfer is still possible
		await unsafe(unsafeSc);
		await unsafe2(unsafeSc);

		// verify the balances
		assert.equal(7, await tk.balanceOf(player1), "incorrect player1 balance after 9 successful transfers");
		assert.equal(6, await tk.balanceOf(player2), "incorrect player2 balance after 4 successful transfers");
		assert.equal(4, await tk.balanceOf(safeSc), "incorrect safeSc balance after 3 successful transfers");
		assert.equal(3, await tk.balanceOf(unsafeSc), "incorrect unsafeSc balance after 2 successful transfers");
	});

	it("transfers: transfer arithmetic check", async() => {
		const tk = await Token.new();

		// enable feature: transfers (required)
		await tk.updateFeatures(FEATURE_TRANSFERS);

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// mint maximum tokens to player 1
		const amt = rnd();
		await tk.mintNative(player1, rnd_max);

		// verify initial amounts
		assert.equal(rnd_max, await tk.balanceOf(player1), "wrong player 1 initial balance");
		assert.equal(0, await tk.balanceOf(player2), "non-zero player 2 initial balance");

		// a function to perform the transfer
		const fn = async(amt) => await tk.transfer(player2, amt, {from: player1});

		// transfer some random number of tokens
		await fn(amt);

		// verify the math works correctly
		assert.equal(rnd_max - amt, await tk.balanceOf(player1), "wrong player 1 balance after transferring some tokens");
		assert.equal(amt, await tk.balanceOf(player2), "wrong player 2 balance after transferring some tokens");

		// transfer all the rest of the tokens
		await assertThrows(fn, rnd_max - amt + 1); // too much
		await fn(rnd_max - amt);

		// verify the math works correctly
		assert.equal(0, await tk.balanceOf(player1), "non-zero player 1 balance after transferring all the tokens");
		assert.equal(rnd_max, await tk.balanceOf(player2), "wrong player 2 balance after transferring all the tokens");
	});
	it("transfers: transfer on behalf arithmetic check", async() => {
		const tk = await Token.new();

		// enable feature: transfers on behalf (required)
		await tk.updateFeatures(FEATURE_TRANSFERS_ON_BEHALF);

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// exchange (account granted to transfer on behalf)
		const exchange = accounts[3];

		// mint maximum tokens to player 1
		const amt = rnd();
		await tk.mintNative(player1, rnd_max);

		// approve all the gems
		await tk.approve(exchange, rnd_max + 2, {from: player1});

		// verify full allowance
		assert.equal(rnd_max + 2, await tk.allowance(player1, exchange), "wrong allowance for exchange by player 1");

		// verify initial amounts
		assert.equal(rnd_max, await tk.balanceOf(player1), "wrong player 1 initial balance");
		assert.equal(0, await tk.balanceOf(player2), "non-zero player 2 initial balance");

		// a function to perform the transfer
		const fn = async(amt) => await tk.transferFrom(player1, player2, amt, {from: exchange});

		// transfer some random number of tokens
		await fn(amt);

		// verify partial allowance
		assert.equal(rnd_max - amt + 2, await tk.allowance(player1, exchange), "wrong allowance for exchange by player 1 after partial transfer");

		// verify the math works correctly
		assert.equal(rnd_max - amt, await tk.balanceOf(player1), "wrong player 1 balance after transferring some tokens");
		assert.equal(amt, await tk.balanceOf(player2), "wrong player 2 balance after transferring some tokens");

		// transfer all the rest of the tokens
		await assertThrows(fn, rnd_max - amt + 1); // too much
		await fn(rnd_max - amt);

		// verify the math works correctly
		assert.equal(0, await tk.balanceOf(player1), "non-zero player 1 balance after transferring all the tokens");
		assert.equal(rnd_max, await tk.balanceOf(player2), "wrong player 2 balance after transferring all the tokens");

		// verify final allowance
		assert.equal(2, await tk.allowance(player1, exchange), "wrong allowance for exchange by player 1 after full transfer");
	});
	it("transfers: transfer / transfer on behalf zero value checks", async() => {
		const tk = await Token.new();

		// enable feature: transfers on behalf (required)
		await tk.updateFeatures(FEATURE_TRANSFERS);

		// players
		const player1 = accounts[1];
		const player2 = accounts[2];

		// mint maximum tokens to player 1
		await tk.mintNative(player1, rnd_max);

		// token transfer function
		const fn = async(to, amt) => await tk.transfer(to, amt, {from: player1});

		// fix some amount to be sent eventually
		const amt = rnd();

		// impossible to transfer to zero address or zero amount
		await assertThrows(fn, player2, 0);
		await assertThrows(fn, 0, amt);
		// impossible to transfer to the player itself
		await assertThrows(fn, player1, amt);

		// successful operation with non-zero values and different address
		await fn(player2, amt);
	});

});

// maximum big number value
const big_max = web3.utils.toBN("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");

// maximum random value (exclusive)
const rnd_max = 4294967296;

// default random function to use
function rnd() {
	return Math.round(Math.random() * rnd_max);
}


// import auxiliary function to ensure function `fn` throws
import {assertThrows} from "../scripts/shared_functions";
