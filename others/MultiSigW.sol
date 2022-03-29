
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
    address[] public owners;
    //verify if an address is owner will return true
    mapping(address => bool) public isOwner;
    //the number of requirements needed to execute a transaction
    uint256 public required;

    //stored all the transactions
    Transaction[] public transactions;

    //stored the approval of each transaction by each owner
    mapping(uint256 => mapping(address => bool)) public approved;

    /// @notice Instanciate the contract
    /// @param _owners address of owners of this multiSig
    /// @param _required number of requireds to execute a transaction

    constructor(address[] memory _owners, uint _required){
        require(_owners.length > 0, "owerns required");
        require(_required > 0 && _required <= _owners.length, "invalid required number of owners");
        for(uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }
}