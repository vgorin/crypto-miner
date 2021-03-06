const FEATURE_TRANSFERS = 0x00000001;
const FEATURE_TRANSFERS_ON_BEHALF = 0x00000002;

const Country = artifacts.require("./CountryERC721");
const Auction = artifacts.require("./DutchAuction");

module.exports = async function(deployer, network, accounts) {
	if(network === "test") {
		console.log("[whitelist country for auction] test network - skipping the migration script");
		return;
	}
	if(network === "coverage") {
		console.log("[whitelist country for auction] coverage network - skipping the migration script");
		return;
	}

	// deployed country token and dutch auction smart contract addresses
	let countryAddress = "0xE49F05Fd6DEc46660221a1C1255FfE335bc7fa7a"; // MainNet country token address
	let auctionAddress = "0x1F4f6625e92C4789dCe4B92886981D7b5f484750"; // MainNet dutch auction instance address
	if(network !== "mainnet") {
		countryAddress = "0x6AC79cbA4Cf4c07303d30410739b13Ee6914b619"; // Rinkeby country token address
		auctionAddress = "0x4Ec415d87e00101867FbfA28Db19cCe0D564D8b3"; // Rinkeby dutch auction instance address
	}

	// link country and auction instances
	const country = Country.at(countryAddress);
	const auction = Auction.at(auctionAddress);

	// allow country transfers on behalf
	await country.updateFeatures(FEATURE_TRANSFERS | FEATURE_TRANSFERS_ON_BEHALF);

	// whitelist country token address
	await auction.whitelist(countryAddress, true);

	console.log("________________________________________________________________________");
	console.log("country:    " + countryAddress);
	console.log("auction:    " + auctionAddress);
};
