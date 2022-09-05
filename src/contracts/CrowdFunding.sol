
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{
    // address key - value - amount sent by contributors
     mapping(address=>uint) public contributors;

     address public admin;
     uint public minimumContribution;
     uint public noOfContributors;
     uint public deadline; // timestamp
     uint public goal;
     uint public raisedAmount;

     constructor(uint _goal,uint _deadline){
        goal=_goal;
        deadline = block.timestamp+ _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;

     }


     // call function when someone wants to send money to the crowdfunding contract

     function contribute() public payable{
        require(block.timestamp<deadline,"DEADLINE HAS PASSED");
        require(msg.value>= minimumContribution,"MINIMUM CONTRIBUTION NOT MET");
         
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
     }


     receive() payable external{
        contribute();
     }


     function getBalance() public view returns(uint) {
        return address(this).balance;
     }


     // getting the refund- function
     
     function getRefund() public{
    
    require(block.timestamp> deadline && raisedAmount < goal);
    require(contributors[msg.sender]>0);

     address payable recipeint = payable(msg.sender);
     uint value = contributors[msg.sender];
     recipeint.transfer(value);
      
      contributors[msg.sender] = 0;
     }

}