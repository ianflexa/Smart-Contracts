
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title A  multiSig require two or more keys to sign and send a transaction
/// @author This is a fork from @SmartContractProgrammer Youtube
/// @notice You can submit and approve a transaction, if the second key approves the same transaction, any one of the owners of this multiSig can execute the transaction. Also, you can revoke your confirmation before the transaction is executed.
/// @dev 

contract MultiSigWallet {
    //Events
    event Deposit(address indexed sender, uint amount);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );

    //store the transaction submitted
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    //stored owners addresses
    address[]public owners;
    //verify if an address is owner will return true
    mapping(address => bool) public isOwner;
    //the number of requirements needed to execute a transaction
    uint256 public required;

}