pragma solidity 0.4.23;

import "./ERC20Receiver.sol";
import "./ERC721Receiver.sol";

/**
 * @dev Dummy Receiver supports both ERC721Receiver and ERC20Receiver
 *      interfaces and is used in tests ONLY
 * @dev Do not deploy and do not use in production!
 */
contract DummyReceiver is ERC20Receiver, ERC721Receiver {
  /**
   * @notice Handle the receipt of a ERC20 token(s)
   * @dev The ERC20 smart contract calls this function on the recipient
   *      after a successful transfer (`safeTransferFrom`).
   *      This function MAY throw to revert and reject the transfer.
   *      Return of other than the magic value MUST result in the transaction being reverted.
   * @notice The contract address is always the message sender.
   *      A wallet/broker/auction application MUST implement the wallet interface
   *      if it will accept safe transfers.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _value amount of tokens which is being transferred
   * @param _data additional data with no specified format
   * @return `bytes4(keccak256("onERC20Received(address,address,uint256,bytes)"))` unless throwing
   */
  function onERC20Received(address _operator, address _from, uint256 _value, bytes _data) external returns(bytes4) {
    // to silence compilation warnings, do something silly with inputs
    require(_operator != address(0) || _from != address(0) || _value != 0 || _data.length != 0);

    // successful only if `_value` is odd, for tests only!
    return _value % 2 == 0? bytes4(""): bytes4(keccak256("onERC20Received(address,address,uint256,bytes)"));
  }

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient after a `transfer`.
   *      This function MAY throw to revert and reject the transfer.
   *      Return of other than the magic value MUST result in the transaction being reverted.
   * @notice The contract address is always the message sender.
   *      A wallet/broker/auction application MUST implement the wallet interface
   *      if it will accept safe transfers.
   * @param _operator address which called `safeTransferFrom` function
   * @param _from address which previously owned the token
   * @param _tokenId NFT identifier which is being transferred
   * @param _data additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` unless throwing
   */
  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4) {
    // to silence compilation warnings, do something silly with inputs
    require(_operator != address(0) || _from != address(0) || _tokenId != 0 || _data.length != 0);

    // successful only if `_tokenId` is odd, for tests only!
    return _tokenId % 2 == 0? bytes4(""): bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }

}
