// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5;

contract SimpleBank {

  /* State variables
   */

  // Private visibility keyword protects user balances from other contracts
  mapping(address => uint) private balances;

  // Public visibility allows contracts to see if a user is enrolled
  mapping(address => bool) public enrolled;

  // Public visibility allows anyone to see the bank owner
  address public owner = msg.sender;

  /* Events - publicize actions to external listeners
   */

  // Event with argument for account enrollment
  event LogEnrolled(address accountAddress);

  // Event with arguments for account and deposit amount
  event LogDepositMade(address accountAddress, uint amount);

  // Event with arguments for account, withdrawal amount, and new balance
  event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance);

  /* Functions
   */

  // Fallback function - Revert if other functions don't match call
  function () external payable {
    revert();
  }

  /// @notice Get balance
  /// @return The balance of the user
  function getBalance() public view returns (uint) {
    // view keyword prevents function from editing state variables
    return balances[msg.sender];
  }

  /// @notice Enroll a customer with the bank
  /// @return The users enrolled status
  // Emit LogEnrolled event
  function enroll() public returns (bool) {
    if (!enrolled[msg.sender]) {
      enrolled[msg.sender] = true;
      emit LogEnrolled(msg.sender);
      return true;
    } else {
      return false;
    }
  }

  /// @notice Deposit ether into bank
  /// @return The balance of the user after the deposit is made
  function deposit() public payable returns (uint) {
    // payable keyword allows function to receive ether
    require(enrolled[msg.sender], "User must be enrolled before deposit");
    balances[msg.sender] += msg.value;
    emit LogDepositMade(msg.sender, msg.value);
    return balances[msg.sender];
  }

  /// @notice Withdraw ether from bank
  /// @dev This does not return any excess ether sent to it
  /// @param withdrawAmount amount you want to withdraw
  /// @return The balance remaining for the user
  function withdraw(uint withdrawAmount) public returns (uint) {
    require(balances[msg.sender] >= withdrawAmount, "Insufficient funds");
    (bool sent, ) = msg.sender.call{value: withdrawAmount}("");
    require(sent, "Failed to send Ether");
    balances[msg.sender] -= withdrawAmount;
    emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
    return balances[msg.sender];
  }
}