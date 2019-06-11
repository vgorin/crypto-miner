// ERC721 and ERC20 Token smart contracts
const GemERC721 = artifacts.require("./GemERC721");
const SilverERC20 = artifacts.require("./SilverERC20");
const GoldERC20 = artifacts.require("./GoldERC20");

// Workshop smart contract
const Workshop = artifacts.require("./Workshop");

// Features and Roles required to be enabled
const FEATURE_UPGRADES_ENABLED = 0x00000001;
const ROLE_TOKEN_DESTROYER = 0x00000002;
const ROLE_LEVEL_PROVIDER = 0x00000040;
const ROLE_GRADE_PROVIDER = 0x00000080;

// Workshop smart contract deployment
module.exports = async function(deployer, network, accounts) {
	if(network === "test") {
		console.log("[deploy workshop] test network - skipping the migration script");
		return;
	}
	if(network === "coverage") {
		console.log("[deploy workshop] coverage network - skipping the migration script");
		return;
	}

	// token dependency configuration
	const conf = network === "mainnet"?
		{ // Mainnet addresses

		}: network === "ropsten"?
		{ // Ropsten addresses
			GemERC721:          "0x60014A33fe30E471c406Ddd99361487Ffe7f1189",
			SilverERC20:        "0x7EDC3fea733E790814e3c2A9D997A55f531D8868",
			GoldERC20:          "0x41FecF81B49B9Bc3eC80EdDdffe266922Ff2BD1f",
		}:
		{ // Rinkeby adddresses
			GemERC721:          "0xd55369023CE587ff1DCC7190f95D3C137E4ca220",
			SilverERC20:        "0x9b2AAA1B68AD54647001b90e8620753D1451ef7a",
			GoldERC20:          "0xADf5116E59e0aDf82EE808b427288C8481b39Efe",
		};

	// deploy workshop
	await deployer.deploy(Workshop, conf.GemERC721, conf.SilverERC20, conf.GoldERC20);

	// for test network assign permissions automatically
	if(network !== "mainnet") {
		// get links to deployed instances
		const instances = {
			GemERC721: await GemERC721.at(conf.GemERC721),
			SilverERC20: await SilverERC20.at(conf.SilverERC20),
			GoldERC20: await GoldERC20.at(conf.GoldERC20),
		};

		const workshop = await Workshop.deployed();
		console.log("updating gem access");
		await instances.GemERC721.updateRole(workshop.address, ROLE_LEVEL_PROVIDER | ROLE_GRADE_PROVIDER);
		console.log("updating silver access");
		await instances.SilverERC20.updateRole(workshop.address, ROLE_TOKEN_DESTROYER);
		console.log("updating gold access");
		await instances.GoldERC20.updateRole(workshop.address, ROLE_TOKEN_DESTROYER);
		console.log("enabling workshop features");
		await workshop.updateFeatures(FEATURE_UPGRADES_ENABLED);
	}
};