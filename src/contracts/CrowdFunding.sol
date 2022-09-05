
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



   // the infor about spending request will be stored in structure variable
     struct Request{
        string description;
        address payable receipient; // this is the person that will get the money
        uint value; // value sent by voters
        // bydefault it is false
        bool completed; // once the contributers have voted for it and the payment has been done, it will be marked as being completed
        uint noOfVoters;
        // default value will be false
        mapping(address =>bool) voters; // voters who are agree to spend the money to given request
     }

// here we cant store this to an array bcz in new versions
// array cant have mapping type stored init
     mapping(uint => Request) public requests;

     uint public numRequests;
   

    // adding events
    event ContributeEvent(address _sender,uint _value);
    event CreateRequestEvent(string _description,address _recipient,uint _value);
    event makePaymentEvent(address _recipient, uint _value);


     // call function when someone wants to send money to the crowdfunding contract

     function contribute() public payable{
        require(block.timestamp<deadline,"DEADLINE HAS PASSED");
        require(msg.value>= minimumContribution,"MINIMUM CONTRIBUTION NOT MET");
         
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
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



// create request function can only be call by admin
        modifier onlyAdmin(){
            require(msg.sender==admin,"only admin can call this function");
            _;
        }
     // creating a spending request
    
    function CreateRequest(string memory _description,address payable _recipient,uint _value) public onlyAdmin{
        // struct must be declare as storage bcz it contains nested mapping here
        // default of the numrequest is zero - so the request starts from index zero
         Request storage newRequest = requests[numRequests];
         newRequest.receipient=_recipient;
         newRequest.description= _description;
         newRequest.value= _value;
         newRequest.completed= false;
         newRequest.noOfVoters =0;

// we can also do this way normally - but here we got the error - bcz the given struct contain nested mapping
// and cant be initiaze with a constructore
      //  requests[numRequests] = Request(_description,_recepient,_value,false,0);



     emit CreateRequestEvent(_description, _recipient, _value);
    }

  // Voting for a Request

   function VoteRequest(uint _requestNo) public{
     require(contributors[msg.sender]>0,'You must be a contributor to vote!');
     Request storage thisRequest = requests[_requestNo];

     require(thisRequest.voters[msg.sender]==false, "You have already voted!");
     thisRequest.voters[msg.sender] = true;
     thisRequest.noOfVoters++;
   }

   // making the payment - call by admin to tranfer the money
   
   function makePayment(uint _requestNo) public onlyAdmin{
    require(raisedAmount>=goal);
    Request storage thisRequest = requests[_requestNo];
    require(thisRequest.completed==false,"This request has been completed");
    require(thisRequest.noOfVoters>noOfContributors/2); // 50% voted fo this request
    thisRequest.receipient.transfer(thisRequest.value);
    thisRequest.completed=true;

    emit makePaymentEvent(thisRequest.receipient, thisRequest.value);
   }



}