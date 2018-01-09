
// ERC20 Compliant?


// Functions needed
// - succession of contract(s) (how is that usually solved?)
// -

// Potential challenges
// - how to pay for initial verification / how to make user pay for that
// - how to make sure that, even if a different service is used to interface with our dapp,
// only one address per profile is allowed?
// -


pragma solidity ^0.4.18;

// This link to the SafeMath file only works in Truffle environment.
import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

contract TokenOfAppreciation {
using SafeMath for uint;

// -- Variables ------------------------------------------------------
    string public constant name = "Token of Appreciation";
    string public constant symbol = "TAP";
    uint8 public constant decimals = 0;

    mapping (address => uint) lastTAP;
    mapping (address => uint) TAPcount;
    address owner;
    uint timeInterval;

// -- Events ----------------------------------------------------------
    event Tapped(address sender, address receiver);
    event Validated(address validatedAddress);

// -- constructor ------------------------------------------------------
    function TokenOfAppreciation () public {
        owner = msg.sender;
        timeInterval = 60; // a minute for debugging purposes.
    }

// -- administration ---------------------------------------------------
    function setTimeInterval(uint _newTimeInterval) public onlyOwner returns (bool){
      timeInterval = _newTimeInterval;
      return true;
    }

// -- core fucntionality -----------------------------------------------
    function tap (address _recipientAddress) public onlyValidated onlyTimeInterval returns (bool) {
            lastTAP[msg.sender] = now;
            TAPcount[_recipientAddress] = TAPcount[_recipientAddress].add(1);
            Tapped(msg.sender, _recipientAddress);
            return true;
    }

      // this function will have to be called before tap can be used.
      // --> how to do this without paying the transaction? Which piece of information could we make
      // send to this function without him being able to fake it?
      // can only be called by owner of contract / c-level?

    function validate (address _fromAddress, address _recipientAddress) public onlyOwner returns(bool) {
        lastTAP[_fromAddress] = now;
        TAPcount[_recipientAddress] = TAPcount[_recipientAddress].add(1);
        Validated(_fromAddress);
        Tapped(_fromAddress, _recipientAddress);
        return true;
    }

// -- static ------------------------------------------------------
    function balanceOf (address _owner) public view returns (uint balance) {
        return TAPcount[_owner];
    }

    function isValidated (address _owner) public view returns (bool) {
        if (lastTAP[_owner] == 0){
            return false;
        }
        return true;
    }

// -- modifiers ---------------------------------------------------
    modifier onlyOwner (){
        require(msg.sender == owner);
        _;
    }

    modifier onlyValidated (){
        require(isValidated(msg.sender));
        _;
    }
    // timeInterval is measured in seconds!
    modifier onlyTimeInterval(){
      require((lastTAP[msg.sender] + timeInterval) < now);
      _;
    }
}
