pragma solidity 0.5.8;

import "./AccessMultiSig.sol";
import "./GemERC721.sol";
import "./GoldERC20.sol";
import "./SilverERC20.sol";
import "./Random.sol";

/**
 * @title Workshop (Gem Upgrade Smart Contract)
 *
 * @notice Workshop smart contract is responsible for gem leveling/upgrading logic;
 *      usually the gem may be upgrading by spending some gold and silver
 *
 * @dev Workshop acts as role provider (ROLE_LEVEL_PROVIDER) and
 *      grade provider (ROLE_GRADE_PROVIDER) for the gem ERC721 token (GemERC721),
 *      providing an ability to level up and upgrade their gems
 * @dev Workshop acts as a token destroyer (ROLE_TOKEN_DESTROYER)
 *      for the gold and silver ERC20 tokens (GoldERC20 and SilverERC20),
 *      consuming (burning) these tokens when leveling and upgrading gem(s)
 *
 * @author Basil Gorin
 */
contract Workshop is AccessMultiSig {
  /**
   * @dev Smart contract unique identifier, a random number
   * @dev Should be regenerated each time smart contact source code is changed
   * @dev Generated using https://www.random.org/bytes/
   */
  uint256 public constant WORKSHOP_UID = 0xe184ae8b021edcf411b9b0c4c78557925fde664f3f3ac5a35fd36355d7946eb0;

  /**
   * @dev Expected version (UID) of the deployed GemERC721 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant GEM_UID_REQUIRED = 0x8012342b1b915598e6a8249110cd9932d7ee7ae8a8a3bbb3a79a5a545cefee72;

  /**
   * @dev Expected version (UID) of the deployed SilverERC20 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant SILVER_UID_REQUIRED = 0xd2ed13751444fdd75b1916ee718753f38af6537fca083868a151de23e07751af;

  /**
   * @dev Expected version (UID) of the deployed GoldERC20 instance
   *      this smart contract is designed to work with
   */
  uint256 public constant GOLD_UID_REQUIRED = 0xfaa04f5eafa80e0f8b560c49d4dffb3ca7e34fd289606af21700ba5685db87bc;

  /**
   * @dev Maximum token level this workshop can level up gem to
   */
  uint8 public constant MAXIMUM_LEVEL_VALUE = 5;

  /**
   * @dev Maximum token grade type this workshop can upgrade a gem to
   */
  uint8 public constant MAXIMUM_GRADE_TYPE = 6;

  /**
   * @notice Number of different grade values defined for a gem
   * @dev Gem grade value is reassigned each time grade type increases,
   *      grade value is generated as non-uniform random in range [0, GRADE_VALUES)
   */
  uint24 public constant GRADE_VALUES = 1000000;

  /**
   * @notice Enables gem leveling up and grade type upgrades
   * @dev Feature FEATURE_UPGRADES_ENABLED must be enabled to
   *      call the `upgrade()` and `bulkUpgrade()` functions
   */
  uint32 public constant FEATURE_UPGRADES_ENABLED = 0x00000001;

  /**
   * @dev Prices of the gem levels 1, 2, 3, 4, 5 accordingly
   * @dev A level up price from level i to level j is calculated
   *      as a difference between level j price and level i price
   */
  uint8[] public LEVEL_PRICES = [0, 5, 20, 65, 200];

  /**
   * @dev Prices of the gem grade types D, C, B, A, AA, AAA accordingly
   * @dev An upgrade price from grade i to grade j is calculated
   *      as a difference between grade j price and grade i price
   * @dev When upgrading grade value only (for grade AAA only),
   *      an upgrade price is calculated as from grade AA to AAA
   */
  uint8[] public GRADE_PRICES = [0, 1, 3, 7, 15, 31];

  /**
   * @dev GemERC721 deployed instance to operate on, gems of that instance
   *      may be upgraded using this smart contract deployed instance
   */
  GemERC721 public gemInstance;

  /**
   * @dev GoldERC20 deployed instance to consume silver from, silver of that instance
   *      may be consumed (burnt) from a player in order to level up a gem
   */
  SilverERC20 public silverInstance;

  /**
   * @dev GoldERC20 deployed instance to consume gold from, gold of that instance
   *      may be consumed (burnt) from a player in order to upgrade a gem
   */
  GoldERC20 public goldInstance;

  /**
   * @dev Fired in upgrade() functions
   * @param tokenId ID of the token which level/grade was modified
   * @param level the level the gem reached after upgrade
   * @param grade the grade (type and value) the gem reached after upgrade
   */
  event UpgradeComplete(uint24 indexed tokenId, uint8 level, uint32 grade);

  /**
   * @dev Creates a workshop instance, binding it to gem (ERC721 token),
   *      silver (ERC20 token) and gold (ERC20 token) instances specified
   * @param gemAddress address of the deployed GemERC721 instance with
   *      the `TOKEN_VERSION` equal to `GEM_TOKEN_VERSION_REQUIRED`
   * @param silverAddress address of the deployed SilverERC20 instance with
   *      the `TOKEN_VERSION` equal to `SILVER_TOKEN_VERSION_REQUIRED`
   * @param goldAddress address of the deployed GoldERC20 instance with
   *      the `TOKEN_VERSION` equal to `GOLD_TOKEN_VERSION_REQUIRED`
   */
  constructor(address gemAddress, address silverAddress, address goldAddress) public {
    // verify the inputs (dummy mistakes only)
    require(gemAddress != address(0));
    require(silverAddress != address(0));
    require(goldAddress != address(0));

    // bind smart contract instances
    gemInstance = GemERC721(gemAddress);
    silverInstance = SilverERC20(silverAddress);
    goldInstance = GoldERC20(goldAddress);

    // verify smart contract versions
    require(gemInstance.TOKEN_UID() == GEM_UID_REQUIRED);
    require(silverInstance.TOKEN_UID() == SILVER_UID_REQUIRED);
    require(goldInstance.TOKEN_UID() == GOLD_UID_REQUIRED);
  }

  /**
   * @notice Calculates amount of silver and gold required to perform
   *      level up and grade upgrade of a particular gem by
   *      level and grade type deltas specified
   * @dev This function contains same logic as in `upgrade()` and can
   *      be used before calling it externally to check
   *      sender has enough silver and gold to perform the transaction
   * @dev Throws if `tokenId` is invalid (non-existent token)
   * @dev Throws if `levelDelta` is invalid, i.e. violates
   *      token level constraints (maximum level)
   * @dev Throws if `gradeTypeDelta` is invalid, i.e. violates
   *      token grade constraints (maximum grade)
   * @dev Throws if `levelDelta` and `gradeTypeDelta` (level delta and
   *      grade delta combination) result in no level/grade change for the gem
   *      (ex.: both `levelDelta` and `gradeTypeDelta` are zero and gem grade is not AAA)
   * @dev Doesn't check token ID ownership, assuming it is checked
   *      when performing an upgrade transaction itself
   * @dev If both `levelDelta` and `gradeTypeDelta` are zeros, assumes
   *      this is a grade value only upgrade (for grade AAA gems)
   * @param tokenId a valid token ID to upgrade grade type for
   * @param levelDelta number of levels to increase token level by
   * @param gradeTypeDelta number of grades to increase token grade by
   * @return tuple containing amounts of silver and gold
   *      required to upgrade the gem
   */
  function getUpgradePrice(
    uint24 tokenId,
    uint8 levelDelta,
    uint8 gradeTypeDelta
  ) public view returns(uint8 silverRequired, uint8 goldRequired) {
    // get gem properties which contains both level and grade
    uint48 properties = gemInstance.getProperties(tokenId);

    // extract current token level
    uint8 currentLevel = uint8(properties >> 32);

    // extract current token grade type
    uint8 currentGradeType = uint8(properties >> 24);

    // calculate new level
    uint8 newLevel = currentLevel + levelDelta;

    // calculate new grade type value
    uint8 newGradeType = currentGradeType + gradeTypeDelta;

    // arithmetic overflow check for level
    require(newLevel >= currentLevel);

    // verify maximum level constraint
    require(newLevel <= MAXIMUM_LEVEL_VALUE);

    // arithmetic overflow check for grade
    require(newGradeType >= currentGradeType);

    // verify maximum grade constraint
    require(newGradeType <= MAXIMUM_GRADE_TYPE);

    // ensure the level and grade type deltas are valid, i.e.
    // either result in level/grade upgrade or the gem is at its
    // maximum grade type and this is a request to upgrade grade value only
    require(levelDelta != 0 || gradeTypeDelta != 0 || currentGradeType == MAXIMUM_GRADE_TYPE);

    // if both level and grade type deltas are zero
    if(levelDelta == 0 && gradeTypeDelta == 0) {
      // this is a grade value only upgrade
      // calculate upgrade price as from grade AA to grade AAA
      goldRequired = GRADE_PRICES[MAXIMUM_GRADE_TYPE - 1] - GRADE_PRICES[MAXIMUM_GRADE_TYPE - 2];

      // return the result immediately
      return (0, goldRequired);
    }

    // calculate silver value required
    silverRequired = LEVEL_PRICES[newLevel - 1] - LEVEL_PRICES[currentLevel - 1];

    // calculate gold value required
    goldRequired = GRADE_PRICES[newGradeType - 1] - GRADE_PRICES[currentGradeType - 1];

    // return the result as tuple
    return (silverRequired, goldRequired);
  }

  /**
   * @notice Levels up and/or upgrades a particular gem
   * @dev Consumes gold and/or silver on success, amounts can be
   *      calculated using `getLevelUpPrice()` and `getUpgradePrice()` functions
   * @dev Throws if at least one of the amounts of silver/gold required to perform
   *      an upgrade exceeds maximum allowed values `silver` and `gold` authorized
   *      to be spent by the transaction sender (player)
   * @dev Increases gem's level and/or grade type by the values specified
   * @dev Throws if `tokenId` is invalid (non-existent token)
   * @dev Throws if `levelDelta` is invalid, i.e. violates
   *      token level constraints (maximum level)
   * @dev Throws if `gradeTypeDelta` is invalid, i.e. violates
   *      token grade constraints (maximum grade)
   * @dev Throws if `levelDelta` and `gradeTypeDelta` (level delta and
   *      grade delta combination) result in no level/grade change for the gem
   *      (ex.: both `levelDelta` and `gradeTypeDelta` are zero and gem grade is not AAA)
   * @dev If both `levelDelta` and `gradeTypeDelta` are zeros, assumes
   *      this is a grade value only upgrade (for grade AAA gems)
   * @dev Requires transaction sender to be an owner of the gem
   * @dev Throws if token owner (transaction sender) has not enough
   *      gold and/or silver on the balance
   * @param tokenId ID of the gem to level up / upgrade
   * @param levelDelta number of levels to increase token level by
   * @param gradeTypeDelta number of grades to increase token grade by
   * @param silver maximum amount of silver sender authorizes smart contract to consume
   * @param gold maximum amount of gold sender authorizes smart contract to consume
   */
  function upgrade(uint24 tokenId, uint8 levelDelta, uint8 gradeTypeDelta, uint8 silver, uint8 gold) public {
    // verify that upgrades are enabled
    require(isFeatureEnabled(FEATURE_UPGRADES_ENABLED));

    // delegate call to `__upgrade`
    __upgrade(uint128(Random.generate256(0)), tokenId, levelDelta, gradeTypeDelta, silver, gold);
  }

  /**
   * @notice Calculates an amount of silver and gold required to perform an upgrade
   * @dev This function contains same logic as in `bulkUpgrade()` and can
   *      be used before calling it externally to check
   *      sender has enough silver and gold to perform the transaction
   * @dev Throws on empty inputs
   * @dev Throws if input arrays differ in size
   * @dev Throws if `tokenIds` contains invalid token IDs
   * @dev Throws if `levelDeltas` contains invalid values, i.e. values
   *      which violate token level constraints (maximum level)
   * @dev Throws if `gradeDeltas` contains invalid values, i.e. values
   *      which violate token grade constraints (maximum grade)
   * @dev Throws if for any token ID in the `tokenIds` array, corresponding
   *      values in `levelDeltas` and `gradeDeltas` (level delta and
   *      grade delta combination) result in no level/grade change for the gem
   * @dev If both `levelDeltas[i]` and `gradeDeltas[i]` are zeros for some `i`,
   *      assumes this is a grade value only upgrade (for grade AAA gems) for that `i`
   * @dev Doesn't check token ID ownership, assuming it is checked
   *      when performing an upgrade transaction itself
   * @param tokenIds an array of valid token IDs to upgrade
   * @param levelDeltas an array of non-zero level deltas, each element
   *      corresponds to an element in tokenIds with the same index
   * @param gradeDeltas an array of non-zero grade deltas, each element
   *      corresponds to an element in tokenIds with the same index
   * @return a tuple of two elements, first represents an amount of
   *      silver required, second – amount of gold required
   */
  function getBulkUpgradePrice(
    uint24[] memory tokenIds,
    uint8[] memory levelDeltas,
    uint8[] memory gradeDeltas
  ) public view returns(
    uint32 silverRequired, // cumulative silver required
    uint32 goldRequired    // cumulative gold required
  ) {
    // perform rough input validations
    require(tokenIds.length != 0);
    require(tokenIds.length == levelDeltas.length);
    require(tokenIds.length == gradeDeltas.length);

    // iterate the data, validate it and perform calculation
    for(uint256 i = 0; i < tokenIds.length; i++) {
      // to assign tuple return value from `getUpgradePrice`
      // we need to define the variables first
      uint8 silverDelta;
      uint8 goldDelta;

      // get amount of silver and gold required to level up and upgrade the gem
      (silverDelta, goldDelta) = getUpgradePrice(tokenIds[i], levelDeltas[i], gradeDeltas[i]);

      // verify the level up / upgrade operation results
      // in the gem's level / grade change:
      // verify at least one of the prices is not zero
      // not required anymore – enforced in `getUpgradePrice()`
      // require(silverDelta != 0 || goldDelta != 0);

      // calculate silver required value and add it to cumulative value
      silverRequired += silverDelta;

      // calculate fold required value and add it to the cumulative value
      goldRequired += goldDelta;
    }

    // return calculated values
    return (silverRequired, goldRequired);
  }

  /**
   * @notice Levels up and/or upgrades several gems in single transaction (bulk mode)
   * @dev Increases all gem's level and/or grade type in the
   *      array specified by the values specified in corresponding input arrays
   * @dev Consumes gold and/or silver on success, amounts required can be
   *      calculated using `getBulkUpgradePrice()` function
   * @dev Throws if at least one of the amounts of silver/gold required to perform
   *      an upgrade exceeds maximum allowed values `silver` and `gold` authorized
   *      to be spent by the transaction sender (player)
   * @dev Throws on empty inputs
   * @dev Throws if input arrays differ in size
   * @dev Throws if `tokenIds` contains invalid token IDs
   * @dev Throws if `levelDeltas` contains invalid values, i.e. values
   *      which violate token level constraints (maximum level)
   * @dev Throws if `gradeDeltas` contains invalid values, i.e. values
   *      which violate token grade constraints (maximum grade)
   * @dev Throws if for any token ID in the `tokenIds` array, corresponding
   *      values in `levelDeltas` and `gradeDeltas` (level delta and
   *      grade delta combination) result in no level/grade change for the gem
   * @dev Requires transaction sender to be an owner of all the gems
   * @dev Throws if token owner (transaction sender) has not enough
   *      gold and/or silver on the balance
   * @param tokenIds an array of valid token IDs to upgrade
   * @param levelDeltas an array of non-zero level deltas, each element
   *      corresponds to an element in tokenIds with the same index
   * @param gradeDeltas an array of non-zero grade deltas, each element
   *      corresponds to an element in tokenIds with the same index
   * @param silver maximum amount of silver sender authorizes smart contract to consume
   * @param gold maximum amount of gold sender authorizes smart contract to consume
   */
  function bulkUpgrade(
    uint24[] memory tokenIds,
    uint8[] memory levelDeltas,
    uint8[] memory gradeDeltas,
    uint32 silver,
    uint32 gold
  ) public {
    // verify that upgrades are enabled
    require(isFeatureEnabled(FEATURE_UPGRADES_ENABLED));

    // perform input array lengths validations
    require(tokenIds.length != 0);
    require(tokenIds.length == levelDeltas.length);
    require(tokenIds.length == gradeDeltas.length);

    // variable to store some randomness to work with
    uint256 rnd;

    // iterate the data and perform an upgrade
    for(uint256 i = 0; i < tokenIds.length; i++) {
      // each 2 iterations starting from iteration 0
      if(i % 2 == 0) {
        // generate new randomness to work with
        rnd = Random.generate256(i / 2);
      }

      // perform an individual gem upgrade, using
      // next 128 bits of randomness we have
      __upgrade(uint128(rnd >> 128 * (i % 2)), tokenIds[i], levelDeltas[i], gradeDeltas[i], silver, gold);
    }
  }

  /**
   * @notice Levels up and/or upgrades a particular gem
   * @dev Increases gem's level and/or grade type by the values specified
   * @dev Throws if `tokenId` is invalid (non-existent token)
   * @dev Throws if `levelDelta` is invalid, i.e. violates
   *      token level constraints (maximum level)
   * @dev Throws if `gradeTypeDelta` is invalid, i.e. violates
   *      token grade constraints (maximum grade)
   * @dev Throws if `levelDelta` and `gradeTypeDelta` (level delta and
   *      grade delta combination) result in no level/grade change for the gem
   *      (ex.: both `levelDelta` and `gradeTypeDelta` are zero and gem grade is not AAA)
   * @dev Requires transaction sender to be an owner of the gem
   * @dev Requires the gem not to be locked (not mining)
   * @dev Throws if token owner (transaction sender) has not enough
   *      gold and/or silver on the balance
   * @dev Consumes gold and/or silver on success, amounts can be
   *      calculated using `getLevelUpPrice()` and `getUpgradePrice()` functions
   * @dev Private, doesn't check if FEATURE_UPGRADES_ENABLED feature is enabled
   * @param rnd128 128 bits of randomness to be used to generate random grade value
   * @param tokenId ID of the gem to level up / upgrade
   * @param levelDelta number of levels to increase token level by
   * @param gradeTypeDelta number of grades to increase token grade by
   * @param silver maximum amount of silver sender authorizes smart contract to consume
   * @param gold maximum amount of gold sender authorizes smart contract to consume
   */
  function __upgrade(
    uint128 rnd128,
    uint24 tokenId,
    uint8 levelDelta,
    uint8 gradeTypeDelta,
    uint32 silver,
    uint32 gold
  ) private {
    // ensure token is owned by the sender, it also ensures token exists
    require(gemInstance.ownerOf(tokenId) == msg.sender);

    // verify token is not locked
    require(gemInstance.isTransferable(tokenId));

    // to assign tuple return value from `getUpgradePrice`
    // we need to define the variables first
    uint8 silverRequired;
    uint8 goldRequired;

    // get amount of silver and gold required to level up and upgrade the gem
    (silverRequired, goldRequired) = getUpgradePrice(tokenId, levelDelta, gradeTypeDelta);

    // ensure we don't spend more silver and gold than allowed
    require(silverRequired <= silver && goldRequired <= gold);

    // verify the level up / upgrade operation results
    // in the gem's level / grade change:
    // verify at least one of the prices is not zero
    // not required anymore – enforced in `getUpgradePrice()`
    // require(silverRequired != 0 || goldRequired != 0);

    // if level up is requested
    if(levelDelta != 0) {
      // burn amount of silver required
      silverInstance.burn(msg.sender, silverRequired);

      // and perform a level up
      gemInstance.levelUpBy(tokenId, levelDelta);
    }

    // if grade type upgrade is requested or
    // if both level and grade deltas are zero –
    // this will be an upgrade price from grade AA to grade AAA
    if(gradeTypeDelta != 0 || levelDelta == 0 && gradeTypeDelta == 0) {
      // perform regular upgrade – grade type and value
      __up(rnd128, tokenId, gradeTypeDelta, goldRequired);
    }

    // emit an event
    emit UpgradeComplete(tokenId, gemInstance.getLevel(tokenId), gemInstance.getGrade(tokenId));
  }

  /**
   * @dev Auxiliary function to perform gem upgrade, grade type
   *      may increase or remain the same, grade value will be increased randomly
   * @dev Unsafe, doesn't make any validations, must be kept private
   * @param rnd128 128 bits of randomness to be used to generate random grade value
   * @param tokenId ID of the gem to upgrade
   * @param gradeTypeDelta number of grades to increase token grade by
   * @param goldRequired amount of gold to consume (burn)
   */
  function __up(uint128 rnd128, uint24 tokenId, uint8 gradeTypeDelta, uint8 goldRequired) private {
    // burn amount of gold required
    goldInstance.burn(msg.sender, goldRequired);

    // read current grade of the token
    uint32 grade = gemInstance.getGrade(tokenId);

    // extract current grade type and increment it by delta
    uint8 gradeType = uint8(grade >> 24) + gradeTypeDelta;

    // extract current grade value
    uint24 gradeValue = randomGradeValue(rnd128, uint24(grade));

    // perform token grade type upgrade
    gemInstance.upgrade(tokenId, uint32(gradeType) << 24 | gradeValue);
  }

  /**
   * @dev Generates new grade value based on the current one using
   *      quadratic random distribution
   * @param rnd128 128 bits of randomness to be used to generate random grade value
   * @param gradeValue current grade value, lower than `GRADE_VALUES`
   * @return new grade value, lower than `GRADE_VALUES`, bigger or equal to current one
   */
  function randomGradeValue(uint128 rnd128, uint24 gradeValue) public pure returns(uint24) {
    // this version of workshop cannot upgrade grades out of `GRADE_VALUES` range
    require(gradeValue < GRADE_VALUES);

    // generate new grade value based on the current one
    gradeValue += uint24(Random.quadratic(rnd128, 128, GRADE_VALUES - gradeValue));

    // return the result
    return gradeValue;
  }

  /**
   * @dev A function to check `randomGradeValue` generation,
   *      see randomGradeValue function
   * @param n how many grade values to generate
   * @return an array of grade values of length n
   */
  function randomGradeValues(uint32 n, uint32 iterations) public view returns(uint24[] memory) {
    // declare a container to store all the generated grades
    uint24[] memory result = new uint24[](n);

    // variable to store some randomness to work with
    uint256 rnd;

    // generate amount of random grade values requested
    for(uint32 i = 0; i < n; i++) {
      // perform `iterations` number of iterations
      for(uint32 j = 0; j < iterations; j++) {
        // each 2 iterations starting from iteration 0
        if((i * iterations + j) % 2 == 0) {
          // generate new randomness to work with
          rnd = Random.generate256((i * iterations + j) / 2);
        }

        // generate random using exactly the same logic as in randomGradeValue
        result[i] = randomGradeValue(uint128(rnd >> 128 * ((i * iterations + j) % 2)), result[i]);
      }
    }

    // return the result
    return result;
  }

}
