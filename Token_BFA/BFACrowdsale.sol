pragma solidity ^0.4.21;

import "./SafeMath.sol";

interface BFAToken {

    function transfer (address receiver, uint256 amount);
}




contract BFACrowdsale{

    using SafeMath for uint;

    //contract owner msg.sender
    address _owner;

    //BFAToken.sol address (must be deployed first)
    BFAToken _tokenReward;
    
    //if crowdsale ended and funding goal reached
    bool public _crowdsaleClosed = false;
    bool public _fundingGoalReached = false;
    

    //available token balance
    uint256 public _available;

    //amount raised in total eth
    uint256 public _amountRaised;
    uint256 public _fundingGoal = 19000 * 1 ether;
    uint8 public _fundingLevel;

    //early sale 10% off
    bool public _earlySale = true;
    uint16 public _earlySaleRate = 12000;
    uint16 public _normalRate = 10000;
    uint256 public _saleEndTime = now + 7 minutes; //end sale after 7 minutes change to days after testing

    //minimum eth purcahse of token
    uint256 public _minEthPerToken = 10000000000000000;  //each purchase must be greater than 0.01 eth

    //start time and end time of crowdsale
    uint256 public _start;  //can remove this
    uint256 public _end;

    //limited allowance for purchase of token per address/user
    mapping (address => uint) private _limits;

    //eth balance in case funding goal is not reached
    mapping ( address => uint256) public _ethUserBalance;  //check see if we send each user their eth balance 
    //in case we reach end of crowdsale without funding goal reached do we need to pay gas for each 
    //user and if so the total balance will be reduced per transfer and we will miss some balance how to fix that????
    //* very important above statement */

    //check reentrance attack
    //add burn function for msg.sender
    //add manual eth fund transfer after level 1 goal is reached by msg.sender
    //add function for msg.sender(owner of contract) to be able to take back tokens lost to contracts

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Buy(address beneficiary, uint amount);  //put events in another file
    event GoalReached( address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    modifier isToken() {
    require(msg.sender == address(_tokenReward));  //recheck this
    _;
  }


    function BFACrowdsale(address addressOfTokenUsedAsReward) public {
        _owner = msg.sender;
        _tokenReward = BFAToken(addressOfTokenUsedAsReward);
        _start = now;
        _end = now + 31 days;
    }



//Initiate CrowdSale
    
    function tokenFallback(address, uint _value, bytes) isToken public {
      _available = _available.add(_value);
  }
    
    
    //uint256 public ethRaised;
    //1. disable _earlySale after one week where to put logic? 2. add limited buying too
    function () payable public{
        require(msg.value > _minEthPerToken);
        require(!_crowdsaleClosed);
        require ((msg.value/(1 ether)) <= _available);
        uint16 _tempPrice;
        if(_earlySale && now > _saleEndTime)
            _earlySale = false;
            
        if(_earlySale)  //1. disable _earlySale after one week where to put logic? 2. add limited buying too
                _tempPrice = _earlySaleRate;
             else 
                 _tempPrice = _normalRate;

            uint256 amount = msg.value;            
            _available = _available.sub((amount/(1 ether)));
            _ethUserBalance[msg.sender] += amount;
            _amountRaised += (amount/(1 ether));
            _tokenReward.transfer(msg.sender, (amount/(1 ether)) * _tempPrice);
            emit Transfer (address(this), msg.sender, (amount/(1 ether)));
        
    }

    function buy() public payable {
      return buyFor(msg.sender);
  }

  function buyFor(address beneficiary) public //available //valid(beneficiary, msg.value) 
      payable {
        require(msg.value > _minEthPerToken);
        require(!_crowdsaleClosed);
        require ((msg.value/(1 ether)) <= _available);
        uint16 _tempPrice;
        if(_earlySale)  //1. disable _earlySale after one week where to put logic? 2. add limited buying too
                _tempPrice = _earlySaleRate;
             else 
                 _tempPrice = _normalRate;

        uint256 amount = msg.value;            
        _available = _available.sub((amount/(1 ether)));
        _ethUserBalance[msg.sender] += amount;
        _amountRaised += (amount/(1 ether));
        _tokenReward.transfer(beneficiary, (amount/(1 ether))* _tempPrice);
        emit Transfer (address(this), beneficiary, (amount/(1 ether)));
  }

    function availableBalance()
        view
        public
        returns (uint) {
          return _available;
  }



    modifier afterDeadline() {
        require( now > _end);
        _;  }


    function checkGoalReached() afterDeadline public {

        if( _amountRaised >= _fundingGoal  )
        {
            _fundingGoalReached = true;
           emit GoalReached (_owner, _amountRaised);
        }
        _crowdsaleClosed = true;
    }


    function safeWithdrawal() afterDeadline public {

        if(!_fundingGoalReached)
        {
            uint256 _amount = _ethUserBalance[msg.sender];
            _ethUserBalance[msg.sender] = 0;

            if( _amount > 0)
            {
                if(msg.sender.send(_amount))
                {
                  emit  FundTransfer(msg.sender, _amount, false);
                }
                else {
                        _ethUserBalance[msg.sender] = _amount;
                }

            }
        }

        if( _fundingGoalReached && _owner == msg.sender)
        {
            if(_owner.send(_amountRaised)){
                emit FundTransfer(_owner, _amountRaised, false);
            }
            else{
                _fundingGoalReached = false;
            }
        }
    }





}