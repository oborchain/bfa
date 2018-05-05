pragma solidity ^0.4.21;


interface ERC20 {

    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transfer(address _to, uint256 _value) public;    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Buy(address beneficiary, uint amount);


}