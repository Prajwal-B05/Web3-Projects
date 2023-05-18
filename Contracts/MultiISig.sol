// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

    contract MultiSig {
     //State variables
     address[] public owners;
     uint txnID;
     uint public required;
     uint transactionCount ;
     struct Transaction 
     {
        address destination;
        uint value;
        bool executed;
        bytes data ;
     }
     mapping(uint => mapping(address => bool)) public confirmations;
     Transaction[] public transactions;

      //Contructor function
      constructor(address[] memory x, uint y) 
       {
        require(x.length >= 0);
        require(y > 0);
        require(y < x.length);
        owners = x;
        }
        
        function isOwner (address addr) private view returns(bool) 
        {
        for(uint i = 0; i < owners.length; i++) 
        {
            if(owners[i] == addr) 
            {
                return true;
            }
        }
        return false;
        }

        receive() payable external 
        {
        
        }


        function executeTransaction(uint transactionId) public 
        {
        require(isConfirmed(transactionId));
        Transaction storage _tx = transactions[transactionId];
        (bool success, ) = _tx.destination.call{ value: _tx.value }(_tx.data);
        require(success);
        _tx.executed = true;
        }
    
        function addTransaction(address payable destination, uint value, bytes memory data ) public returns(uint) 
        {
        transactions[transactionCount] = Transaction(destination, value, false ,data);
        transactionCount += 1;
        return transactionCount - 1;
        }

        
      function isConfirmed(uint transactionId) public view returns(bool) 
      {
        return getConfirmationsCount(transactionId) >= required;
      }


        function confirmTransaction(uint transactionId) public 
        {
        require(isOwner(msg.sender));
        confirmations[transactionId][msg.sender] = true;
        if(isConfirmed(transactionId)) 
          {
            executeTransaction(transactionId);
          }
        }

           function submitTransaction(address payable dest, uint value , bytes memory data) external 
           {
            uint id = addTransaction(dest, value , data);
            confirmTransaction(id);
           }


        function getConfirmationsCount(uint transactionId) public view returns(uint) 
        {
        uint count;
        for(uint i = 0; i < owners.length; i++) 
          {
            if(confirmations[transactionId][owners[i]]) 
            {
                count++;
            }
          }
        return count;
        }

    }

   

