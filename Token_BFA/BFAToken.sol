pragma solidity ^0.4.21;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./Addresses.sol";


interface ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract BFAToken is ERC20{

    //Using external libraries
    using SafeMath for uint;
    using Addresses for address;

    //internal variables
    string internal _symbol;
    string internal _name;

    uint8 internal _decimals;
    uint256 internal _totalSupply;

    //mapping for user token balance, ethereum balance (in case we cant reach goal), and allowance for withdrawal by third party
    mapping (address => uint256) internal _tokenBalance;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => uint256) internal _ethBalance;

    function BFAToken  (string symbol, string name, uint8 decimals, uint256 totalSupply ) public {

        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
        _tokenBalance[msg.sender] = _totalSupply;

    }

    function name()
    public view
    returns (string){
        return _name;
    }

    function symbol()
    public view returns (string){
        return _symbol;
    }

    function decimals()
    public view returns (uint8){
        return _decimals;
    }

    function totalSupply()
    public view returns (uint256){
        return _totalSupply;
    }


    function balanceOf(address _owner) public view returns (uint256){
            return _tokenBalance[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool){

        if (_tokenBalance[msg.sender] >= _value)
        {
            _allowances[msg.sender][_spender] = _value;
            emit Approval (msg.sender, _spender, _value);
            return true;
        }
        return false;

    }


    function allowance(address _owner, address _spender) public view returns (uint256){

        return _allowances[_owner][_spender];
    }


    //recheck function here
    function _transfer(address _from, address _to, uint256 _value) internal{

        require(_to != 0x0);
        require(_tokenBalance[_from] >= _value);
        require(_tokenBalance[_to] + _value >= _tokenBalance[_to]);
        
            if (_to.isContract()) {
              ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
              _contract.tokenFallback(_from, _value, "_data");  //check these 2 lines to make sure error free
            }

            uint256 _previousBalance = _tokenBalance[_from] + _tokenBalance[_to];

            _tokenBalance[_from] = _tokenBalance[_from].sub(_value);
            _tokenBalance[_to] = _tokenBalance[_to].add(_value);
            emit Transfer(_from, _to, _value);
            assert(_tokenBalance[_from] + _tokenBalance[_to] == _previousBalance);
            
    }
    //recheck above function

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    //recheck below function
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        require (_value <= _allowances[_from][msg.sender]);
        require (_value > 0);
        _allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
       }
    //recheck above function



    

}