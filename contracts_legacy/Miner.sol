pragma solidity 0.4.23;

import "./AccessControlLight.sol";
import "./GemERC721.sol";
import "./GemExtension.sol";
import "./PlotERC721.sol";
import "./SilverERC20.sol";
import "./GoldERC20.sol";
import "./ArtifactERC20.sol";
import "./FoundersKeyERC20.sol";
import "./ChestKeyERC20.sol";
import "./Math.sol";
import "./TierMath.sol";
import "./Random.sol";

/**
 * @title Miner
 *
 * @notice Miner is responsible for mining mechanics of the CryptoMiner World
 *      and allows game tokens (ERC721 and ERC20) to interact with each other
 *
 * @dev Miner may read, write, mint, lock and unlock tokens
 *      (locked tokens cannot be transferred i.e. cannot change owner)
 *
 * @dev Following tokens may be accessed for reading (token properties affect mining):
 *      - GemERC721
 *      - PlotERC721
 *      - ArtifactERC721
 *
 * @dev Following tokens may be accessed for writing (token properties change when mining):
 *      - PlotERC721
 *
 * @dev Following tokens may be minted (token can be found in the land plot when mining):
 *      - GemERC721
 *      - ArtifactERC721
 *      - SilverERC20
 *      - GoldERC20
 *      - ArtifactERC20 // TODO: to be removed after ArtifactERC721 release
 *      - FoundersKeyERC20
 *      - ChestKeyERC20
 *
 * @dev Following tokens may be locked or unlocked (tokens are locked when mining):
 *      - GemERC721
 *      - PlotERC721
 *      - ArtifactERC721
 *
 * @author Basil Gorin
 */
// TODO: deployment gas usage exceeds 4,500,000!
contract Miner is AccessControlLight {
  /**
   * @dev Smart contract unique identifier, a random number
   * @dev Should be regenerated each time smart contact source code is changed
   * @dev Generated using https://www.random.org/bytes/
   */
  uint256 public constant MINER_UID = 0xb96e87e6b91c9d6cc34a588dc6b461822f6ef3cd4726a448513cabc14a95d269;

  /**
   * @dev Expected version (UID) of the deployed GemERC721 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant GEM_UID_REQUIRED = 0x0000000000000000000000000000000000000000000000000000000000000003;

  /**
   * @dev Expected version (UID) of the deployed GemExtension instance
   *      this smart contract is designed to work with
   */
  uint256 public constant GEM_EXT_UID_REQUIRED = 0x5907e0ef0cc11bd9c3b6f14fe92523435d27e8da304e24c1918ab0d37f9fb096;

  /**
   * @dev Expected version (UID) of the deployed PlotERC721 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant PLOT_UID_REQUIRED = 0x216c71f30bc2bf96dd0dfeae5cf098bfe9e0da295785ebe16a6696b0d997afec;

  /**
   * @dev Expected version (UID) of the deployed ArtifactERC721 instance
   *      this smart contract is designed to work with
   */
  // TODO: this value should be defined later, after ArtifactERC721 smart contract is released
  uint256 public constant ARTIFACT_UID_REQUIRED = 0x0000000000000000000000000000000000000000000000000000000000000000;

  /**
   * @dev Expected version (UID) of the deployed SilverERC20 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant SILVER_UID_REQUIRED = 0x0000000000000000000000000000000000000000000000000000000000000030;

  /**
   * @dev Expected version (UID) of the deployed GoldERC20 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant GOLD_UID_REQUIRED = 0x00000000000000000000000000000000000000000000000000000000000000300;

  /**
   * @dev Expected version (UID) of the deployed ArtifactERC20 instance
   *      this smart contract is designed to work with
   */
  // TODO: this may be completely removed after ArtifactERC721 release
  uint256 public constant ARTIFACT_ERC20_UID_REQUIRED = 0xfe81d4b23218a9d32950b26fad0ab9d50928ece566126c1d1bf0c1bfe2666da6;

  /**
   * @dev Expected version (UID) of the deployed FoundersKeyERC20 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant FOUNDERS_KEY_UID_REQUIRED = 0x70221dffd5103663ba8bf65a43517466ba616c4937710b99c7f003a7ae99fbc7;

  /**
   * @dev Expected version (UID) of the deployed ChestKeyERC20 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant CHEST_KEY_UID_REQUIRED = 0xbf1ea2fd198dbe93f19827f1e3144b045734667c5483124adc3715df6ce853f6;

  /**
   * @dev Auxiliary data structure used in `miningPlots` mapping to
   *      store information about gems and artifacts bound tto mine
   *      a particular plot of land
   * @dev Additionally it stores address of the player who initiated
   *      the `bind()` transaction and its unix timestamp
   */
  struct MiningData {
    /**
     * @dev ID of the gem which is mining the plot,
     *      the gem is locked when mining
     */
    uint32 gemId;

    /**
     * @dev ID of the artifact which is mining the plot,
     *      the artifact is locked when mining
     */
    uint16 artifactId;

    /**
     * @dev A player, an address who initiated `bind()` transaction
     */
    address player;

    /**
     * @dev Unix timestamp of the `bind()` transaction
     */
    uint32 bound;
  }

  /**
   * @dev GemERC721 deployed instance,
   *      tokens of that instance can be read, minted, locked and unlocked
   *
   * @dev Miner should have `GemERC721.ROLE_TOKEN_CREATOR` permission to mint tokens
   * @dev Miner should have `GemERC721.ROLE_STATE_PROVIDER` permission lock/unlock tokens
   */
  GemERC721 public gemInstance;

  /**
   * @dev GemERC721 Extension deployed instance, extends GemERC721 instance
   *
   * @dev Miner should have `GemExtension.ROLE_NEXT_ID_INC` permission
   *      to increment token ID sequence counter
   */
  GemExtension public gemExt;

  /**
   * @dev PlotERC721 deployed instance,
   *      tokens of that instance can be modified (mined), locked and unlocked
   *
   * @dev Miner should have `PlotERC721.ROLE_OFFSET_PROVIDER` permission to modify (mine) tokens
   * @dev Miner should have `PlotERC721.ROLE_STATE_PROVIDER` permission lock/unlock tokens
   */
  PlotERC721 public plotInstance;

  /**
   * @dev ArtifactERC721 deployed instance,
   *      tokens of that instance can be read, minted, locked and unlocked
   *
   * @dev Miner should have `ArtifactERC721.ROLE_TOKEN_CREATOR` permission to mint tokens
   * @dev Miner should have `ArtifactERC721.ROLE_STATE_PROVIDER` permission lock/unlock tokens
   */
  // TODO: uncomment when ready
  //ArtifactERC721 public artifactInstance;

  /**
   * @dev SilverERC20 deployed instance,
   *      tokens of that instance can be minted
   *
   * @dev Miner should have `SilverERC20.ROLE_TOKEN_CREATOR` permission to mint tokens
   */
  SilverERC20 public silverInstance;

  /**
   * @dev GoldERC20 deployed instance,
   *      tokens of that instance can be minted
   *
   * @dev Miner should have `GoldERC20.ROLE_TOKEN_CREATOR` permission to mint tokens
   */
  GoldERC20 public goldInstance;

  /**
   * @dev GoldERC20 deployed instance,
   *      tokens of that instance can be minted
   *
   * @dev Miner should have `GoldERC20.ROLE_TOKEN_CREATOR` permission to mint tokens
   */
  // TODO: to be removed when ArtifactERC721 is ready
  ArtifactERC20 public artifactErc20Instance;

  /**
   * @dev FoundersKeyERC20 deployed instance,
   *      tokens of that instance can be minted
   *
   * @dev Miner should have `FoundersKeyERC20.ROLE_TOKEN_CREATOR` permission to mint tokens
   */
  FoundersKeyERC20 public foundersKeyInstance;

  /**
   * @dev ChestKeyERC20 deployed instance,
   *      tokens of that instance can be minted
   *
   * @dev Miner should have `ChestKeyERC20.ROLE_TOKEN_CREATOR` permission to mint tokens
   */
  ChestKeyERC20 public chestKeyInstance;


  /**
   * @dev Mapping to store mining information that is which
   *      gems and artifacts mine which plots
   * @dev See `MiningData` data structure for more details
   */
  mapping(uint24 => MiningData) public miningPlots;

  /**
   * @dev How many minutes of mining (resting) energy it takes
   *      to mine block of land depending on the tier number
   * @dev Array is zero-indexed, index 0 corresponds to Tier 1,
   *      index 4 corresponds to Tier 5
   */
  uint16[] public MINUTES_TO_MINE = [30, 240, 720, 1440, 2880];

  /**
   * @notice Enables mining, that is the main feature of miner
   * @dev Required for `bind()` function to work properly
   */
  uint32 public constant FEATURE_MINING_ENABLED = 0x00000001;

  /**
   * @dev Enables updating and releasing the gem/plot/artifact on behalf
   * @dev Allows to call `update()` and `release()` on behalf of someone else
   */
  uint32 public constant ROLE_MINING_OPERATOR = 0x00000001;

  /**
   * @dev Enables rollback functionality
   * @dev Allows to call `rollback()` function
   */
  uint32 public constant ROLE_ROLLBACK_OPERATOR = 0x00000002;

  /**
   * @dev A bitmask indicating locked state of the ERC721 token
   * @dev Consists of a single bit at position 1 – binary 1
   * @dev The bit meaning in token's `state` is as follows:
   *      0: locked
   *      1: unlocked
   */
  uint8 public constant DEFAULT_MINING_BIT = 0x1; // bit number 1

  /**
   * @dev A mask used to erase `DEFAULT_MINING_BIT`
   */
  uint8 public constant ERASE_MINING_BIT = 0xFF ^ DEFAULT_MINING_BIT;

  /**
   * @dev May be fired in `bind()`
   * @param _by an address which executed transaction, usually player, owner of the gem
   * @param gemId ID of the gem whose energy was consumed
   * @param energyLeft how much energy has left
   */
  event RestingEnergyConsumed(address indexed _by, uint32 indexed gemId, uint32 energyLeft);

  /**
   * @dev May be fired in `bind()`
   * @param _by an address which executed transaction, usually owner of the tokens
   * @param plotId ID of the plot to mine (bound)
   * @param gemId ID of the gem which mines the plot (bound)
   * @param artifactId ID of the artifact used (bound)
   */
  event Bound(address indexed _by, uint24 indexed plotId, uint32 indexed gemId, uint16 artifactId);

  /**
   * @dev May be fired in `bind()` and `release()`. Fired in `update()`
   * @param _by an address which executed transaction, usually owner of the plot
   * @param plotId ID of the plot which was mined
   * @param offsetFrom initial depth for the plot
   * @param offsetTo mined depth for the plot
   * @param loot an array containing loot
   */
  event Updated(
    address indexed _by,
    uint24 indexed plotId,
    uint8 offsetFrom,
    uint8 offsetTo,
    uint16[] loot
  );

  /**
   * @dev Fired in `release()`
   * @param _by an address which executed transaction, usually owner of the tokens
   * @param plotId ID of the plot released
   * @param gemId ID of the gem released
   * @param artifactId ID of the artifact released
   */
  event Released(address indexed _by, uint24 indexed plotId, uint32 indexed gemId, uint16 artifactId);


  /**
   * @dev Creates a Miner instance, binding it to GemERC721, PlotERC721,
   *      ArtifactERC721, SilverERC20, GoldERC20, ArtifactERC20,
   *      FoundersKeyERC20, ChestKeyERC20 token instances specified
   * @param _gem address of the deployed GemERC721 instance with
   *      the `TOKEN_VERSION` equal to `GEM_UID_REQUIRED`
   * @param _plot address of the deployed PlotERC721 instance with
   *      the `TOKEN_UID` equal to `PLOT_UID_REQUIRED`
   * @param _artifact address of the deployed ArtifactERC721 instance with
   *      the `TOKEN_UID` equal to `ARTIFACT_UID_REQUIRED`
   * @param _silver address of the deployed SilverERC20 instance with
   *      the `TOKEN_VERSION` equal to `SILVER_UID_REQUIRED`
   * @param _gold address of the deployed GoldERC20 instance with
   *      the `TOKEN_VERSION` equal to `GOLD_UID_REQUIRED`
   * @param _artifactErc20 address of the deployed ArtifactERC20 instance with
   *      the `TOKEN_UID` equal to `ARTIFACT_ERC20_UID_REQUIRED`
   * @param _foundersKey address of the deployed FoundersKeyERC20 instance with
   *      the `TOKEN_UID` equal to `FOUNDERS_KEY_UID_REQUIRED`
   * @param _chestKey address of the deployed ChestKeyERC20 instance with
   *      the `TOKEN_UID` equal to `CHEST_KEY_UID_REQUIRED`
   */
  constructor(
    address _gem,
    address _gemExt,
    address _plot,
    address _artifact,
    address _silver,
    address _gold,
    address _artifactErc20,
    address _foundersKey,
    address _chestKey
  ) public {
    // check input addresses for zero values
    require(_gem != address(0));
    require(_gemExt != address(0));
    require(_plot != address(0));
    require(_artifact != address(0));
    require(_silver != address(0));
    require(_gold != address(0));
    require(_artifactErc20 != address(0));
    require(_foundersKey != address(0));
    require(_chestKey != address(0));

    // bind smart contract instances
    gemInstance = GemERC721(_gem);
    gemExt = GemExtension(_gemExt);
    plotInstance = PlotERC721(_plot);
    //artifactInstance = ArtifactERC721(_artifact); // TODO: uncomment
    silverInstance = SilverERC20(_silver);
    goldInstance = GoldERC20(_gold);
    artifactErc20Instance = ArtifactERC20(_artifactErc20);
    foundersKeyInstance = FoundersKeyERC20(_foundersKey);
    chestKeyInstance = ChestKeyERC20(_chestKey);

    // verify smart contract versions
    require(gemInstance.TOKEN_VERSION() == GEM_UID_REQUIRED);
    require(gemExt.EXTENSION_UID() == GEM_EXT_UID_REQUIRED);
    require(plotInstance.TOKEN_UID() == PLOT_UID_REQUIRED);
    //require(artifactInstance.TOKEN_UID() == ARTIFACT_UID_REQUIRED); // TODO: uncomment
    require(silverInstance.TOKEN_VERSION() == SILVER_UID_REQUIRED);
    require(goldInstance.TOKEN_VERSION() == GOLD_UID_REQUIRED);
    require(artifactErc20Instance.TOKEN_UID() == ARTIFACT_ERC20_UID_REQUIRED);
    require(foundersKeyInstance.TOKEN_UID() == FOUNDERS_KEY_UID_REQUIRED);
    require(chestKeyInstance.TOKEN_UID() == CHEST_KEY_UID_REQUIRED);
  }

  /**
   * @notice Binds a gem and (optionally) an artifact to a land plot
   *      and starts mining of the plot
   * @dev Locks all the tokens passed as parameters
   * @dev Throws if any of the tokens is already locked
   * @dev Throws if any of the tokens specified doesn't exist or
   *      doesn't belong to transaction sender
   * @param plotId ID of the land plot to mine
   * @param gemId ID of the gem to mine land plot with
   * @param artifactId ID of the artifact to affect the gem
   *      properties during mining process
   */
  function bind(uint24 plotId, uint32 gemId, uint16 artifactId) public {
    // verify mining feature is enabled
    require(isFeatureEnabled(FEATURE_MINING_ENABLED));

    // verify all the tokens passed belong to sender,
    // verifies token existence under the hood
    require(plotInstance.ownerOf(plotId) == msg.sender);
    require(gemInstance.ownerOf(gemId) == msg.sender);
    //require(artifactId == 0 || artifactInstance.ownerOf(artifactId) == msg.sender); // TODO: uncomment

    // verify all tokens are not in a locked state
    require(plotInstance.getState(plotId) & DEFAULT_MINING_BIT == 0);
    require(gemInstance.getState(gemId) & DEFAULT_MINING_BIT == 0);
    //require(artifactId == 0 || artifactInstance.getState(artifactId) & DEFAULT_MINING_BIT == 0); // TODO: uncomment

    // read tiers structure of the plot
    uint64 tiers = plotInstance.getTiers(plotId);

    // read level data of the gem
    uint8 level = gemInstance.getLevel(gemId);

    // determine maximum depth this gem can mine to (by level)
    uint8 maxOffset = TierMath.getTierDepthOrMined(tiers, level);

    // determine gem's effective resting energy, taking into account its grade
    uint32 energy = effectiveRestingEnergyOf(gemId);

    // define variable to store new plot offset
    uint8 offset;

    // delegate call to `evaluateWith`
    (offset, energy) = evaluateWith(tiers, maxOffset, energy);

    // in case when offset has increased, we perform initial mining
    // in the same transaction
    if(offset > TierMath.getOffset(tiers)) {
      // delegate call to `__mine` to update plot and mint loot
      __mine(plotId, offset);

      // save unused resting energy into gem's extension
      gemExt.write(gemId, energy, 0, 32);
      // keeping it unlocked and updating state change date
      gemInstance.setState(gemId, 0);

      // emit an energy consumed event
      emit RestingEnergyConsumed(msg.sender, gemId, energy);
    }

    // if gem's level allows to mine deeper,
    if(offset < maxOffset) {
      // lock the plot, erasing everything else in its state
      plotInstance.setState(plotId, DEFAULT_MINING_BIT);
      // lock the gem, erasing everything else in its state
      gemInstance.setState(gemId, DEFAULT_MINING_BIT);
      // lock artifact if any, also erasing everything in its state
      // artifactInstance.setState(artifactId, DEFAULT_MINING_BIT);

      // store mining information in the internal mapping
      miningPlots[plotId] = MiningData({
        gemId: gemId,
        artifactId: artifactId,
        player: msg.sender,
        bound: uint32(now)
      });

      // emit en event
      emit Bound(msg.sender, plotId, gemId, artifactId);
    }
  }

  /**
   * @notice Releases a gem and an artifact (if any) bound earlier
   *      with `bind()` from a land plot and stops mining of the plot
   * @dev Saves updated land plot state into distributed ledger and may
   *      produce (mint) some new tokens (silver, gold, etc.)
   * @dev Unlocks all the tokens involved (previously bound)
   * @dev Throws if land plot token specified doesn't exist or
   *      doesn't belong to transaction sender
   * @dev Throws if land plot specified is not in mining state
   *      (was not bound previously using `bind()`)
   * @param plotId ID of the land plot to stop mining
   */
  function release(uint24 plotId) public {
    // verify sender is owner of the plot or mining operator
    // verifies plot existence under the hood
    require(plotInstance.ownerOf(plotId) == msg.sender || isSenderInRole(ROLE_MINING_OPERATOR));

    // evaluate the plot
    uint8 offset = evaluate(plotId);

    // if offset changed
    if(offset != plotInstance.getOffset(plotId)) {
      // delegate call to `__mine` to update plot and mint loot
      __mine(plotId, offset);
    }

    // unlock the tokens - delegate call to `__unlock`
    __unlock(plotId);
  }

  /**
   * @notice Updates plot state without releasing a gem and artifact (if any)
   *      bound earlier with `bind()` from a land plot, doesn't stop mining
   * @dev Saves updated land plot state into distributed ledger and may
   *      produce (mint) some new tokens (silver, gold, etc.)
   * @dev All the tokens involved (previously bound) remain in a locked state
   * @dev Throws if land plot token specified doesn't exist or
   *      doesn't belong to transaction sender
   * @dev Throws if land plot specified is not in mining state
   *      (was not bound previously using `bind()`)
   * @param plotId ID of the land plot to update state for
   */
  function update(uint24 plotId) public {
    // verify sender is owner of the plot or mining operator
    // verifies plot existence under the hood
    require(plotInstance.ownerOf(plotId) == msg.sender || isSenderInRole(ROLE_MINING_OPERATOR));

    // evaluate the plot
    uint8 offset = evaluate(plotId);

    // delegate call to `__mine` to update plot and mint loot
    __mine(plotId, offset);

    // if plot is fully mined now
    if(plotInstance.isFullyMined(plotId)) {
      // unlock the tokens - delegate call to `__unlock`
      __unlock(plotId);
    }
    // if plot still can be mined do not unlock
    else {
      // load binding data
      MiningData memory m = miningPlots[plotId];

      // erase gem's energy by updating extension
      gemExt.write(m.gemId, 0, 0, 32);
      // keeping it locked and updating state change date
      gemInstance.setState(m.gemId, DEFAULT_MINING_BIT);
    }
  }

  /**
   * @dev Service function to unlock plot and associated gem and artifact if any
   * @dev Reverts the mining (doesn't update plot)
   * @dev May be executed only by rollback operator
   * @param plotId ID of the plot to unlock
   */
  function rollback(uint24 plotId) public {
    // ensure function is called by rollback operator
    require(isSenderInRole(ROLE_ROLLBACK_OPERATOR));

    // unlock the tokens - delegate call to `__unlock`
    __unlock(plotId);
  }

  /**
   * @dev Auxiliary function to release plot and all bound tokens
   * @dev Unsafe, must be kept private
   * @param plotId ID of the plot to unlock
   */
  function __unlock(uint24 plotId) private {
    // load binding data
    MiningData memory m = miningPlots[plotId];

    // unlock the plot, erasing everything else in its state
    plotInstance.setState(plotId, 0);
    // unlock the gem, erasing everything else in its state
    gemInstance.setState(m.gemId, 0);
    // unlock artifact if any, erasing everything in its state
    // artifactInstance.setState(m.artifactId, 0);

    // erase mining information in the internal mapping
    delete miningPlots[plotId];

    // emit en event
    emit Released(msg.sender, plotId, m.gemId, m.artifactId);
  }

  /**
   * @notice Evaluates current state of the plot without performing a transaction
   * @dev Doesn't update land plot state in the distributed ledger
   * @dev Used internally by `release()` and `update()` to calculate state of the plot
   * @dev May be used by frontend to display current mining state close to realtime
   * @param plotId ID of the land plot to evaluate current state for
   * @return evaluated current mining block index for the given land plot
   */
  function evaluate(uint24 plotId) public constant returns(uint8 offset) {
    // verify plot is locked
    // verifies token existence under the hood
    require(plotInstance.getState(plotId) & DEFAULT_MINING_BIT != 0);

    // load binding data
    MiningData memory m = miningPlots[plotId];

    // ensure binding data entry exists
    require(m.bound != 0);

    // read tiers structure of the plot
    uint64 tiers = plotInstance.getTiers(plotId);

    // read level data of the gem
    uint8 level = gemInstance.getLevel(m.gemId);

    // determine maximum depth this gem can mine to (by level)
    uint8 maxOffset = TierMath.getTierDepthOrMined(tiers, level);

    // determine gem's effective mining energy
    uint32 energy = effectiveMiningEnergyOf(m.gemId);

    // delegate call to `evaluateWith`
    (offset, energy) = evaluateWith(tiers, maxOffset, energy);

    // calculated offset returned automatically
    return offset;
  }

  /**
   * @notice Evaluates current state of the plot without performing a transaction
   * @dev Doesn't update land plot state in the distributed ledger
   * @dev Used internally by `release()` and `update()` to calculate state of the plot
   * @dev May be used by frontend to display current mining state close to realtime
   * @param tiers tiers data structure of the land plot to evaluate current state for
   * @param maxOffset maximum offset the gem can mine to
   * @param initialEnergy available energy to be spent by the gem
   * @return a tuple containing:
   *      offset – evaluated current mining block index for the given land plot
   *      energy - energy left after mining
   */
  function evaluateWith(
    uint64 tiers,
    uint8 maxOffset,
    uint32 initialEnergy
  ) private constant returns(
    uint8 offset,
    uint32 energyLeft
  ) {
    // determine current plot offset, this will also be returned
    offset = TierMath.getOffset(tiers);

    // verify the gem can mine that plot
    require(offset < maxOffset);

    // init return energy value with an input one
    energyLeft = initialEnergy;

    // in case when energy is not zero, we perform initial mining
    // in the same transaction
    if(energyLeft != 0) {
      // iterate over all tiers
      for(uint8 i = 1; i <= TierMath.getNumberOfTiers(tiers); i++) {
        // determine tier offset
        uint8 tierDepth = TierMath.getTierDepth(tiers, i);

        // if current tier depth is bigger than offset – we mine
        if(offset < tierDepth) {
          // determine how deep we can mine in that tier
          uint8 canMineTo = offset + energyToBlocks(i, energyLeft);

          // we are not crossing the tier though
          uint8 willMineTo = uint8(Math.min(canMineTo, tierDepth));

          // determine how much energy is consumed and decrease energy
          energyLeft -= blocksToEnergy(i, willMineTo - offset);

          // update offset
          offset = willMineTo;

          // if we don't have enough energy to mine deeper
          // or gem level doesn't allow to mine deeper
          if(offset >= maxOffset || canMineTo <= tierDepth) {
            // we're done, exit the loop
            break;
          }
        }
      }
    }
  }

  /**
   * @dev Auxiliary function which performs mining of the plot
   * @dev Unsafe, must be kept private at all times
   * @param plotId ID of the plot to mine
   * @param offset depth to mine the plot to,
   *      must be bigger than current plot depth
   */
  function __mine(uint24 plotId, uint8 offset) private {
    // get tiers structure of the plot
    uint64 tiers = plotInstance.getTiers(plotId);

    // extract current offset
    uint8 offset0 = TierMath.getOffset(tiers);

    // ensure new offset is bigger than initial one
    require(offset0 < offset);

    // packed structure to accumulate results
    uint16[] memory loot = new uint16[](9);

    // get indexes of first and last tiers
    uint8 tier0 = TierMath.getTierIndex(tiers, offset0);
    uint8 tier1 = TierMath.getTierIndex(tiers, offset);

    // if we do not cross tiers
    if(tier0 == tier1) {
      // just process current tier according to offsets
      loot = genLoot(tier0, offset - offset0, TierMath.isBottomOfStack(tiers, offset), loot);
    }
    // otherwise, if we cross one or more tiers
    else {
      // process first tier
      loot = genLoot(tier0, TierMath.getTierDepth(tiers, tier0 + 1) - offset0, false, loot);

      // process middle tiers
      for(uint8 i = tier0 + 1; i <= tier1 - 1; i++) {
        // process full tier `i`
        loot = genLoot(i, TierMath.getTierDepth(tiers, i - i) - TierMath.getTierDepth(tiers, i), false, loot);
      }

      // process last tier
      loot = genLoot(tier1, offset - TierMath.getTierDepth(tiers, tier1 - 1), TierMath.isBottomOfStack(tiers, offset), loot);
    }

    // loot processing - delegate call to `processLoot`
    __processLoot(loot, plotId, tiers);

    // update plot's offset
    plotInstance.mineTo(plotId, offset);

    // emit an event
    emit Updated(msg.sender, plotId, offset0, offset, loot);
  }

  /**
   * @dev Auxiliary function to mint the loot defined in input array:
   *      index 0: gems level 1
   *      index 1: gems level 2
   *      index 2: gems level 3
   *      index 3: gems level 4
   *      index 4: gems level 5
   *      index 5: silver
   *      index 6: gold
   *      index 7: artifacts
   *      index 8: keys
   * @dev The loot is minted to transaction sender
   * @dev Unsafe, must be kept private at all times
   * @param loot an array defining the loot as described above
   * @param plotId ID of the plot the gem is found in
   * @param tiers tiers structure of the plot
   */
  function __processLoot(uint16[] memory loot, uint24 plotId, uint64 tiers) private {
    // mint gems level 1, 2, 3, 4, 5
    for(uint8 i = 0; i < 5; i++) {
      // mint gems level `i`
      __mintGems(i + 1, loot[i], plotId, TierMath.getTierDepth(tiers, i + 1));
    }

    // if there is silver to mint
    if(loot[5] != 0) {
      // mint silver
      silverInstance.mint(msg.sender, loot[5]);
    }

    // if there is gold to mint
    if(loot[6] != 0) {
      // mint gold
      goldInstance.mint(msg.sender, loot[6]);
    }

    // if there are artifacts to mint
    if(loot[7] != 0) {
      // mint artifacts
      artifactErc20Instance.mint(msg.sender, loot[7]);
    }

    // if there are keys to mint
    if(loot[8] != 0) {
      // mint keys
      // plots in Antarctica have zero country ID (high 8 bits)
      if(plotId >> 16 == 0) {
        // for Antarctica we mint founder's chest keys
        foundersKeyInstance.mint(msg.sender, loot[8]);
      }
      else {
        // for the rest of the World - regular chest keys
        chestKeyInstance.mint(msg.sender, loot[8]);
      }
    }
  }

  /**
   * @dev Auxiliary function to mint gems
   * @dev The loot is minted to transaction sender
   * @dev Unsafe, must be kept private at all times
   * @param level level of the gems to mint
   * @param n number of gems to mint
   * @param plotId ID of the plot the gem is found in
   * @param depth block depth where the gem was found
   */
  function __mintGems(uint8 level, uint16 n, uint24 plotId, uint16 depth) private {
    // we're about to mint `n` gems
    for(uint16 i = 0; i < n; i++) {
      // to generate grade type we need some random first
      uint256 gradeTypeRnd = Random.__randomValue(0x10000 + i, 0, 10000);

      // define variable to store grade type
      uint8 gradeType;

      // grade D: 50%
      if(gradeTypeRnd < 5000) {
        gradeType = 1;
      }
      // grade C: 37%
      else if(gradeTypeRnd < 8700) {
        gradeType = 2;
      }
      // grade B: 10%
      else if(gradeTypeRnd < 9700) {
        gradeType = 3;
      }
      // grade A: 2.5%
      else if(gradeTypeRnd < 9950) {
        gradeType = 4;
      }
      // grade A: 0.49%
      else if(gradeTypeRnd < 9999) {
        gradeType = 5;
      }
      // grade AAA: 0.01%
      else {
        gradeType = 6;
      }

      // mint the gem with randomized properties
      gemInstance.mint(
        msg.sender,
        gemExt.incrementId(),
        plotId,
        depth,
        i,
        gemExt.randomColor(0x10100 + i),
        level,
        gradeType,
        uint24(Random.__randomValue(0x10200 + i, 0, 1000000))
      );
    }
  }

  /**
   * @dev Auxiliary function to generate loot when mining `n` blocks in tier `k`
   * @dev Loot data is accumulated in `loot` array, containing:
   *      index 0: gems level 1
   *      index 1: gems level 2
   *      index 2: gems level 3
   *      index 3: gems level 4
   *      index 4: gems level 5
   *      index 5: silver
   *      index 6: gold
   *      index 7: artifacts
   *      index 8: keys
   * @param k one-based tier index to process loot for
   * @param n number of blocks to process for tier specified
   * @param bos bottom of stack indicator, true if plot is fully mined
   * @param loot an array containing loot information
   */
  function genLoot(uint8 k, uint16 n, bool bos, uint16[] memory loot) public constant returns(uint16[]) {
    // for each block out of `n` blocks in tier `k`
    // we need to generate up to 11 random numbers,
    // with the precision up to 0.01%, that is 10^-4

    // for tier 1
    if(k == 1) {
      // gem (lvl 1): 1.2%
      loot[0] += rndEval(0, 120, n);
      // gem (lvl 2): 0.4%
      loot[1] += rndEval(n, 40, n);
      // silver (1pc): 9%
      loot[5] += rndEval(2 * n, 900, n);
      // silver (5pcs): 0.5%
      loot[5] += 5 * rndEval(3 * n, 50, n);
      // silver (15pcs): 0.1%
      loot[5] += 15 * rndEval(4 * n, 10, n);
    }
    // for tier 2
    else if(k == 2) {
      // gem (lvl 1): 1.9%
      loot[0] += rndEval(0, 190, n);
      // gem (lvl 2): 0.8%
      loot[1] += rndEval(n, 80, n);
      // gem (lvl 3): 0.2%
      loot[2] += rndEval(2 * n, 20, n);
      // silver (1pc): 12%
      loot[5] += rndEval(3 * n, 1200, n);
      // silver (5pcs): 1%
      loot[5] += 5 * rndEval(4 * n, 100, n);
      // silver (15pcs): 0.2%
      loot[5] += 15 * rndEval(5 * n, 20, n);
      // artifact: 0.01%
      loot[7] += rndEval(6 * n, n, 1);
    }
    // for tier 3
    else if(k == 3) {
      // gem (lvl 1): 1.1%
      loot[0] += rndEval(0, 110, n);
      // gem (lvl 2): 1.3%
      loot[1] += rndEval(n, 130, n);
      // gem (lvl 3): 0.6%
      loot[2] += rndEval(2 * n, 60, n);
      // gem (lvl 4): 0.04%
      loot[3] += rndEval(3 * n, 4, n);
      // silver (1): 4%
      loot[5] += rndEval(4 * n, 400, n);
      // silver (5): 4%
      loot[5] += 5 * rndEval(5 * n, 400, n);
      // silver (15): 0.6%
      loot[5] += 15 * rndEval(6 * n, 60, n);
      // gold (1): 0.01%
      loot[6] += rndEval(7 * n, n, 1);
      // artifact: 0.04%
      loot[7] += rndEval(8 * n, 4, n);
    }
    // for tier 4
    else if(k == 4) {
      // gem (lvl 1): 0.6%
      loot[0] += rndEval(0, 60, n);
      // gem (lvl 2): 1%
      loot[1] += rndEval(n, 100, n);
      // gem (lvl 3): 2.2%
      loot[2] += rndEval(2 * n, 220, n);
      // gem (lvl 4): 0.12%
      loot[3] += rndEval(3 * n, 12, n);
      // silver (1): 3%
      loot[5] += rndEval(4 * n, 300, n);
      // silver (5): 5%
      loot[5] += 5 * rndEval(5 * n, 500, n);
      // silver (15): 1.2%
      loot[5] += 15 * rndEval(6 * n, 120, n);
      // gold (1): 0.02%
      loot[6] += rndEval(7 * n, 2, n);
      // artifact: 0.13%
      loot[7] += rndEval(8 * n, 13, n);
    }
    // for tier 5
    else if(k == 5) {
      // gem (lvl 1): 0.4%
      loot[0] += rndEval(0, 40, n);
      // gem (lvl 2): 1.2%
      loot[1] += rndEval(n, 120, n);
      // gem (lvl 3): 3.7%
      loot[2] += rndEval(2 * n, 370, n);
      // gem (lvl 4): 0.5%
      loot[3] += rndEval(3 * n, 50, n);
      // gem (lvl 5): 0.04%
      loot[4] += rndEval(4 * n, 4, n);
      // silver (1): 2%
      loot[5] += rndEval(5 * n, 200, n);
      // silver (5): 7%
      loot[5] += 5 * rndEval(6 * n, 700, n);
      // silver (15): 5%
      loot[5] += 15 * rndEval(7 * n, 500, n);
      // gold (1): 0.05%
      loot[6] += rndEval(8 * n, 5, n);
      // artifact: 0.4%
      loot[7] += rndEval(9 * n, 40, n);
      // key: 0.02%
      loot[8] += rndEval(10 * n, 2, n);
    }
    // any other tier is invalid
    else {
      // throw an exception
      require(false);
    }

    // for bottom of the stack
    if(bos) {
      // determine how many items we get
      uint256 items = Random.__randomValue(11 * n, 2, 5);

      // generate that amount of items
      for(uint8 i = 0; i < items; i++) {
        // generate random value in range [0, 10000)
        uint256 rnd10000 = Random.__randomValue(11 * n + 1 + i, 0, 10000);

        // generate loot according to the probabilities
        // gem (lvl 1): 1%
        if(rnd10000 < 100) {
          loot[0]++;
        }
        // gem (lvl 2): 7%
        else if(rnd10000 < 800) {
          loot[1]++;
        }
        // gem (lvl 3): 14%
        else if(rnd10000 < 2200) {
          loot[2]++;
        }
        // gem (lvl 4): 8.5%
        else if(rnd10000 < 3050) {
          loot[3]++;
        }
        // gem (lvl 5): 2%
        else if(rnd10000 < 3250) {
          loot[4]++;
        }
        // silver (1): none
        // silver (5): 40.37%
        else if(rnd10000 < 7287) {
          loot[5] += 5;
        }
        // silver (15): 26%
        else if(rnd10000 < 9887) {
          loot[5] += 15;
        }
        // gold (1): 0.3%
        else if(rnd10000 < 9917) {
          loot[6]++;
        }
        // artifact: 0.8%
        else if(rnd10000 < 9997) {
          loot[7]++;
        }
        // key: 0.03%
        else {
          loot[8]++;
        }
      }
    }

    // return the loot
    return loot;
  }

  /**
   * @dev Auxiliary function to calculate amount of successful experiments
   *      in `n` iterations with the `p` probability each
   * @param seedOffset seed offset to be used for random generation, there
   *      will be `n` of seeds used [seedOffset, seedOffset + n)
   * @param p probability of successful event in bp (basis point, ‱)
   * @param n number of experiments to launch
   */
  function rndEval(uint16 seedOffset, uint16 p, uint16 n) public constant returns(uint16 amount) {
    // we perform `iterations` number of iterations
    for(uint16 i = 0; i < n; i++) {
      // for each iteration we check if we've got a probability hit
      if(Random.__randomValue(seedOffset + i, 0, 10000) < p) {
        // and if yes we increase the counter
        amount++;
      }
    }

    // return the result
    return amount;
  }

  /**
   * @notice Binds several gems and (optionally) artifacts to land plots
   *      and starts mining of these plots in a single transaction
   * @dev Bulk version of the `bind()` function
   * @dev Locks all the tokens passed as parameters
   * @dev Throws if any of the tokens is already locked
   * @dev Throws if any of the tokens specified doesn't exist or
   *      doesn't belong to transaction sender
   * @dev Throws if arrays lengths provided mismatch
   * @dev Throws if arrays provided contain duplicates
   * @dev Throws if arrays specified are zero-sized
   * @param plotIds an array of IDs of the land plots to mine
   * @param gemIds an array of IDs of the gems to mine land plots with
   * @param artifactIds an array of IDs of the artifacts to affect the gems
   *      properties during mining process
   */
  function bulkBind(uint24[] plotIds, uint32[] gemIds, uint16[] artifactIds) public {
    // verify arrays have same lengths
    require(plotIds.length == gemIds.length);
    require(plotIds.length == artifactIds.length);

    // ensure arrays are not zero sized
    require(plotIds.length != 0);

    // simply iterate over each element
    for(uint32 i = 0; i < plotIds.length; i++) {
      // delegate call to `bind`
      bind(plotIds[i], gemIds[i], artifactIds[i]);
    }
  }

  /**
   * @notice Releases several gems and artifacts (if any) bound earlier
   *      with `bind()` or `bulkBind()` from land plots and stops mining of plots
   * @dev Bulk version of the `release()` function
   * @dev Saves updated land plots states into distributed ledger and may
   *      produce (mint) some new tokens (silver, gold, etc.)
   * @dev Unlocks all the tokens involved (previously bound)
   * @dev Throws if array specified is zero-sized
   * @dev Throws if any of the land plot tokens specified
   *      doesn't exist or doesn't belong to transaction sender
   * @dev Throws if any of the land plots specified is not in mining state
   *      (was not bound previously using `bind()` or `bulkBind()`)
   * @param plotIds an array of IDs of the land plots to stop mining
   */
  function bulkRelease(uint24[] plotIds) public {
    // ensure arrays are not zero sized
    require(plotIds.length != 0);

    // simply iterate over each element
    for(uint32 i = 0; i < plotIds.length; i++) {
      // delegate call to `release`
      release(plotIds[i]);
    }
  }

  /**
   * @notice Updates several plots states without releasing gems and artifacts (if any)
   *      bound earlier with `bind()` or `bulkBind()` from land plots, doesn't stop mining
   * @dev Bulk version of the `update()` function
   * @dev Saves updated land plots states into distributed ledger and may
   *      produce (mint) some new tokens (silver, gold, etc.)
   * @dev All the tokens involved (previously bound) remain in a locked state
   * @dev Throws if array specified is zero-sized
   * @dev Throws if any of the land plot tokens specified
   *      doesn't exist or doesn't belong to transaction sender
   * @dev Throws if any of the land plots specified is not in mining state
   *      (was not bound previously using `bind()` or `bulkBind()`)
   * @param plotIds an array of IDs of the land plots to update states for
   */
  function bulkUpdate(uint24[] plotIds) public {
    // ensure arrays are not zero sized
    require(plotIds.length != 0);

    // simply iterate over each element
    for(uint32 i = 0; i < plotIds.length; i++) {
      // delegate call to `update`
      update(plotIds[i]);
    }
  }

  /**
   * @notice Evaluates current state of several plots without performing a transaction
   * @dev Bulk version of the `evaluate()` function
   * @dev Doesn't update land plots states in the distributed ledger
   * @dev May be used by frontend to display current mining state close to realtime
   * @dev Throws if array specified is zero-sized
   * @dev Throws if any of the land plots specified is not in mining state
   *      (was not bound previously using `bind()` or `bulkBind()`)
   * @param plotIds an array of IDs of the land plots to evaluate current states for
   * @return an array of evaluated current mining block indexes for the given land plots array
   */
  function bulkEvaluate(uint24[] plotIds) public constant returns(uint8[] offsets) {
    // ensure arrays are not zero sized
    require(plotIds.length != 0);

    // allocate memory for the array
    offsets = new uint8[](plotIds.length);

    // simply iterate over each element
    for(uint32 i = 0; i < plotIds.length; i++) {
      // delegate call to `evaluate`
      offsets[i] = evaluate(plotIds[i]);
    }

    // offsets array is returned automatically
    return offsets;
  }


  /**
   * @dev Finds a gem bound to a particular plot
   * @param plotId ID of the plot to query bound gem for
   * @return ID of the bound gem
   */
  function getBoundGemId(uint24 plotId) public constant returns(uint32) {
    // load binding data
    MiningData memory m = miningPlots[plotId];

    // ensure binding data entry exists
    require(m.bound != 0);

    // return the result
    return m.gemId;
  }

  /**
   * @dev Finds a gem bound to a particular plot
   * @param plotId ID of the plot to query bound gem for
   * @return ID of the bound gem
   */
  function getBoundArtifactId(uint24 plotId) public constant returns(uint32) {
    // load binding data
    MiningData memory m = miningPlots[plotId];

    // ensure binding data entry exists
    require(m.bound != 0);

    // return the result
    return m.artifactId;
  }

  /**
   * @notice Determines how deep can particular gem mine on a particular plot
   * @dev This function verifies current plot offset and based on the gem's level
   *      and plot's offset determines how deep this gem can mine
   * @dev Throws if the gem or plot specified doesn't exist
   * @param gemId ID of the gem to use
   * @param plotId ID of the plot to mine
   * @return number of blocks the gem can mine, zero if it cannot mine more
   */
  function gemMinesTo(uint32 gemId, uint24 plotId) public constant returns(uint8) {
    // delegate call to `levelAllowsToMineTo`
    return TierMath.getTierDepthOrMined(plotInstance.getTiers(plotId), gemInstance.getLevel(gemId));
  }

  /**
   * @notice Determines how many minutes of energy is required to mine
   *      `n` blocks of tier number `tier`
   * @dev See also `energyToBlocks` function
   * @param tier tier number of interest
   * @param n number of blocks to mine in the specified tier
   * @return required energy in minutes
   */
  function blocksToEnergy(uint8 tier, uint8 n) public constant returns(uint32) {
    // calculate based on the tier number and return
    // array bounds keep tier index to be valid
    return MINUTES_TO_MINE[tier - 1] * n;
  }

  /**
   * @notice Determines how many blocks in tier number `tier` can be
   *      mined using the energy of `energy` minutes
   * @dev See also `blocksToEnergy` function
   * @param tier tier number of interest
   * @param energy available energy in minutes
   * @return number of blocks which can be mined
   */
  function energyToBlocks(uint8 tier, uint32 energy) public constant returns(uint8) {
    // calculate based on the tier number and return
    // array bounds keep tier index to be valid
    return uint8(Math.min(energy / MINUTES_TO_MINE[tier - 1], 0xFF));
  }

  /**
   * @notice Determines effective mining energy of a particular gem
   * @notice Gems of any grades accumulate mining energy when mining
   * @dev See `energeticAgeOf` and `effectiveEnergy` functions for more details
   * @dev Throws if the gem specified doesn't exist
   * @param gemId ID of the gem to calculate effective mining energy for
   * @return effective mining energy for the specified gem
   */
  function effectiveMiningEnergyOf(uint32 gemId) public constant returns(uint32) {
    // determine mining energy of the gem,
    // by definition it's equal to its energetic age
    // verifies gem's existence under the hood
    uint32 energy = energeticAgeOf(gemId);

    // if energy is not zero
    if(energy != 0) {
      // convert mining energy into effective mining energy
      energy = effectiveEnergy(energy, gemInstance.getGrade(gemId));
    }

    // return energy value
    return energy;
  }

  /**
   * @notice Determines effective resting energy of a particular gem
   * @notice Gems of grades A, AA and AAA accumulate resting energy when not mining
   * @dev See `restingEnergyOf` and `effectiveEnergy` functions for more details
   * @dev Throws if the gem specified doesn't exist
   * @param gemId ID of the gem to calculate effective resting energy for
   * @return effective resting energy for the specified gem
   */
  function effectiveRestingEnergyOf(uint32 gemId) public constant returns(uint32) {
    // determine resting energy of the gem
    // verifies gem's existence under the hood
    uint32 energy = restingEnergyOf(gemId);

    // if energy is not zero (grades A, AA and AAA)
    if(energy != 0) {
      // convert resting energy into effective resting energy
      energy = effectiveEnergy(energy, gemInstance.getGrade(gemId));
    }

    // return energy value
    return energy;
  }

  /**
   * @notice Calculates effective energy of the gem based on its base energy and grade
   * @dev Effective energy is base energy multiplied by mining rate of the gem
   * @param energy base energy of the gem
   * @param grade full grade value of the gem, containing grade type and value
   * @return effective energy of the gem in minutes
   */
  function effectiveEnergy(uint32 energy, uint32 grade) public pure returns(uint32) {
    // calculate mining rate of the gem
    // delegate call to `miningRate`
    uint32 r = miningRate(grade);

    // determine effective gem energy of the gem,
    // taking into account its mining rate,
    // and return the result
    return uint32(uint64(energy) * r / 100000000);
  }

  /**
   * @notice Determines mining rate of a particular gem based on its grade
   * @dev See `miningRate` function for more details
   * @dev Throws if gem specified doesn't exist
   * @param gemId ID of the gem to calculate mining rate for
   * @return mining rate of the gem multiplied by 10^8
   */
  function miningRateOf(uint32 gemId) public constant returns(uint32) {
    // read the grade of the given gem
    // verifies gem existence under the hood
    uint32 grade = gemInstance.getGrade(gemId);

    // calculate mining rate - delegate call to `miningRate`
    // and return the result
    return miningRate(grade);
  }

  /**
   * @notice Calculates mining rate of the gem by its grade
   * @dev Calculates mining rate `r` of the gem, based on its grade type `e`
   *      and grade value `u` according to the formulas:
   *        r = 1 + (e - 1) * 10^-1 + 5 * u * 10^-8, e = [1, 2, 3]
   *        r = 1.4 + 15 * u * 10^-8, e = 4
   *        r = 2 + 2 * u * 10^-7, e = 5
   *        r = 4 + u * 10^-6, e = 6
   * @dev Gem's grade type and value are extracted from the packed `grade`
   * @dev The value returned is multiplied by 10^8
   * @param grade grade of the gem,
   *      high 8 bits of which contain grade type e = [1, 2, 3, 4, 5, 6]
   *      low 24 bits contain grade value u = [0, 1000000)
   * @return `r * 10^8`, where `r` is the mining rate of the gem of grade `grade`
   */
  function miningRate(uint32 grade) public pure returns(uint32) {
    // extract grade type of the gem - high 8 bits
    uint32 e = grade >> 24;

    // extract grade value of the gem - low 24 bits
    uint32 u = 0xFFFFFF & grade;

    // for grades D, C, B: e = [1, 2, 3]
    if(e == 1 || e == 2 || e == 3) {
      // r = 1 + (e - 1) * 10^-1 + 5 * u * 10^-8
      return 100000000 + 10000000 * (e - 1) + 5 * u;
    }

    // for grade A: e = 4
    if(e == 4) {
      // r = 1.4 + 15 * u * 10^-8
      return 140000000 + 15 * u;
    }

    // for grade AA: e = 5
    if(e == 5) {
      // r = 2 + 2 * u * 10^-7
      return 200000000 + 20 * u;
    }

    // for grade AAA: e = 6
    if(e == 6) {
      // r = 4 + u * 10^-6
      return 400000000 + 100 * u;
    }

    // if we get here it means the grade is not valid
    // grade is not one of D, C, B, A, AA, AAA
    // throw an exception
    require(false);

    // return fallback default value equal to one
    return 100000000;
  }

  /**
   * @notice Calculates resting energy for the gem specified,
   *      see `restingEnergy` for more details on resting energy
   * @notice The gem accumulates resting energy when it's not mining
   * @dev Throws if gem with the given ID doesn't exist
   * @param gemId ID of the gem to calculate resting energy for
   * @return resting energy of the given gem
   */
  function restingEnergyOf(uint32 gemId) public constant returns(uint16) {
    // determine gems' grade type
    // verifies gem existence under the hood
    uint8 e = gemInstance.getGradeType(gemId);

    // resting energy is defined only for gems with grade A, AA and AAA
    if(e < 4) {
      // for grades D, C and B it is zero by definition
      return 0;
    }

    // determine energetic age of the gem - delegate call to `energeticAgeOf`
    uint32 age = energeticAgeOf(gemId);

    // calculate the resting energy - delegate call to `restingEnergy`
    // and return the result
    return restingEnergy(age);
  }

  /**
   * @notice Resting Energy (R) formula implementation:
   *      R = -7 * 10^-6 * a^2 + 0.5406 * a, if a < 37193
   *      R = 10423 + 0.0199 * (a - 37193), if a >= 37193,
   *      where `a` stands for Energetic Age of the gem (minutes)
   * @dev Linear threshold `37193` in the equation above is
   *      the root of the equation `-7 * 10^-6 * x^2 + 0.5406x = 0.0199`,
   *      where x is gem age in minutes and `k = 0.0199` is energy increase per minute,
   *      which is calculated as `k = 10437 / 525600`,
   *      where `525600 = 365 * 24 * 60` is number of minutes in one year and `n = 10437`
   *      is the right root of equation `-7 * 10^-6 * x^2 + 0.5406x = 0`,
   *      `n` is the number of minutes to parabola peak
   * @param energeticAge number of minutes the gem was not mining
   * @return Resting Energy (R) calculated based on Energetic Age (a) provided
   */
  function restingEnergy(uint32 energeticAge) public pure returns(uint16) {
    // to avoid arithmetic overflow we need to use significantly more
    // bits than the original 32-bit number, 128 bits is more than enough
    uint128 a = energeticAge;

    // the result of the calculation is stored in 128-bit integer as well
    uint128 energy = 0;

    // perform calculation according to the formula (see function header)
    // if a < 37193:
    if(a < 37193) {
      // R = -7 * 10^-6 * a^2 + 0.5406 * a
      energy = 2703 * a / 5000 - 7 * a ** 2 / 1000000;
    }
    // if a >= 37193
    else {
      // R = 10423 + 0.0199 * (a - 37193)
      energy = 10423 + (a - 37193) * 199 / 10000;
    }

    // cast the result into uint16, maximum value 65535
    // corresponds to energetic age of 2,806,625 minutes,
    // which is approximately 5 years and 124 days,
    // that should be more than enough
    return energy > 0xFFFF? 0xFFFF : uint16(energy);
  }

  /**
   * @dev Energetic age is an approximate number of minutes the gem accumulated energy
   * @dev The time is measured from the time when gem modified its properties
   *      (level or grade) or its state for the last time till now
   * @dev If the gem didn't change its properties ot state since its genesis,
   *      the time is measured from gem's creation time
   * @dev For resting (non-mining) gems of grades A, AA and AAA energetic age
   *      is used to calculate their resting energy
   * @dev For mining gems of any grade energetic age is equal to mining energy
   * @param gemId ID of the gem to calculate energetic age for
   * @return energetic age of the gem in minutes
   */
  function energeticAgeOf(uint32 gemId) public constant returns(uint32) {
    // gem's age in blocks is defined as a difference between current block number
    // and the maximum of gem's levelModified, gradeModified, creationTime and stateModified
    uint32 ageBlocks = uint32(block.number - Math.max(
      Math.max(gemInstance.getLevelModified(gemId), gemInstance.getGradeModified(gemId)),
      Math.max(gemInstance.getCreationTime(gemId),  gemInstance.getStateModified(gemId))
    ));

    // average block time is 15 seconds, meaning that approximately
    // 4 blocks correspond to one minute of energetic age
    uint32 ageMinutes = ageBlocks / 4;

    // return the result
    return ageMinutes;
  }

}

