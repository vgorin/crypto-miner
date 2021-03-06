pragma solidity 0.4.23;

import "./FoundersPlots.sol";

/**
 * @dev Founders Plots Mock, simplest FoundersPlots implementation,
 *      returning 65,535 plots for any address except zero address
 */
contract FoundersPlotsMock is FoundersPlots {
  /**
   * @dev Dummy implementation returning 65,535 for all inputs except zero
   *      input which results in zero output
   * @param addr address to query balance for
   * @return 65,535 if address is not zero, zero otherwise
   */
  function geodeBalances(address addr) external constant returns (uint16) {
    // check input and return 65,535
    return addr == address(0)? 0: 0xFFFF;
  }
}
