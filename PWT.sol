pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract ERC20 {
    string	public name;
    string	public symbol;
    uint8 	public decimals;
    uint256 public totalSupply;

	/*
		@param _owner The address from which the balance will be retrieved
		@return The balance
	*/
    function balanceOf(address _rcpt) public constant returns (uint256 balance);

    /* 
		@notice send `_value` token to `_to` from `msg.sender`
		@param _to The address of the recipient
		@param _value The amount of token to be transferred
		@return Whether the transfer was successful or not
	*/
    function transfer(address _to, uint256 _value) public returns (bool success);
	
	/*
		@notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
		@param _from The address of the sender
		@param _to The address of the recipient
		@param _value The amount of token to be transferred
		@return Whether the transfer was successful or not
	*/
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

	/*
		@notice `msg.sender` approves `_spender` to spend `_value` tokens
		@param _spender The address of the account able to transfer the tokens
		@param _value The amount of tokens to be approved for transfer
		@return Whether the approval was successful or not
	*/
    function approve(address _spender, uint256 _value) public returns (bool success);

	/*
		@param _owner The address of the account owning tokens
		@param _spender The address of the account able to transfer the tokens
		@return Amount of remaining tokens allowed to spent
	*/
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
/* --------------------------------------------------------------------------------------*/
contract owned {
    address public _owner;
    function construct() public {_owner = msg.sender;}
	
    modifier onlyOwner {
        require(msg.sender == _owner);
		_;
    }
}
/* --------------------------------------------------------------------------------------*/

contract PWT is ERC20,owned{
	using SafeMath for uint256;
	
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowed;
	
	event Burn(address indexed from, uint256 value);
	
	function construct(uint256 initialSupply,string tokenName,uint8 decimalUnits,string tokenSymbol) public  {		
		_balances[_owner] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
	} 

    /** Destroy tokens */
    function burn(uint256 _value) public onlyOwner returns (bool success) {
		_balances[msg.sender]=_balances[msg.sender].sub(_value);
		totalSupply=totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
	
	function balanceOf(address _recipient) public constant returns (uint256 balance) {
		if(_balances[_recipient]>0){
			return _balances[_recipient];
		}
		return 0x0;
	}

	function balanceOfOwner() public onlyOwner view returns (uint256 balance) {
		if(_balances[msg.sender]>0){
			return _balances[msg.sender];
		}
		return 0x0;
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {
		//Default assumes totalSupply can't be over max (2^256 - 1).
		//require(balances[msg.sender] >= _value);
		require(_to != 0x0 && _balances[msg.sender] >= _value && (_balances[_to] + _value > _balances[_to]));
		_balances[msg.sender]=_balances[msg.sender].sub(_value);
		_balances[_to] = _balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
		//require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        require(_to != 0x0 && _balances[_from] >= _value && _allowed[_from][msg.sender] >= _value && (_balances[_to] + _value > _balances[_to]));
        
		_balances[_from] = _balances[_from].sub(_value);
		_balances[_to] = _balances[_to].add(_value);
		_allowed[_from][msg.sender]=_allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
		require(_balances[msg.sender] >= _value);
		_allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return _allowed[_owner][_spender];
    }
}



