// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (finance/Vesting.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vesting is Ownable , ReentrancyGuard {

    event PayeeAdded(address account, uint256 shares);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);


    uint256 public startTime;
    
    uint256 private oneDay = 5 seconds;
    uint256 private totalDays = 730;

    uint256 private _totalShares;
    uint256 public adminID = type(uint256).max; 
    uint256 private run;
    
    IERC20 token;
    mapping(uint256 => uint256) private _shares;

    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(uint256 => uint256)) private _erc20Released;

    mapping(address => uint256) private _indexes;

    mapping(uint256 => address) public _idToAddress;
    mapping(address => uint256) public _addressToID;

    mapping(uint256 => bool) public _exist;

    uint256 Total = (88888888 *10**18/100) * 10 ;

    
    constructor( uint256 _time ){
  
        startTime = block.timestamp + _time;

        _idToAddress[adminID] = owner();
        _addressToID[owner()] = adminID;

    }

    function setToken(IERC20 _token) public onlyOwner {
        token = _token;
    }

   
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    
    function totalReleased() public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    
    function shares(address account) public view returns (uint256) {
        return _shares[_addressToID[account]];
    }


    
    function released(address account) public view returns (uint256) {
        return _erc20Released[token][_addressToID[account]];
    }

    
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    function daysDifference() public view returns(uint256){
        if(block.timestamp< startTime){
            return 0;
        }else{
             return (block.timestamp - startTime) / oneDay;
        }
    }

    function _userShare(address account) public view returns(uint256) {
        if(account == owner()){
            return _totalShares;
        }else{
            uint256 id = _addressToID[account];
            return _shares[id];
        }
    }

    function lockedBalance(address account) public view returns(uint256){
        uint256 totalReceived = ((Total ) / totalDays ) * totalDays;
        uint256 payment = _pendingPayment(account, totalReceived, released(account));
        return payment;
    }

    
    function release(address account) public virtual nonReentrant {
        uint256 id = _addressToID[account];
        require(_shares[id] > 0, "Vesting: account has no shares");

        uint256 payment = _pending(account);

        require(payment != 0, "Vesting: account is not due payment");

        _erc20Released[token][id] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }
    

    
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) { 
        return (totalReceived * _userShare(account)) / _totalShares - alreadyReleased;
    }

    function _pending(
        address account
    ) public view returns (uint256) {
        uint256 Days = daysDifference();
        if(daysDifference() > totalDays)
        Days = totalDays;
        uint256 totalReceived = ((Total ) / totalDays ) * Days;
        uint256 payment = _pendingPayment(account, totalReceived, released(account));
        return payment;
    }

    function _addPayees(address[] memory payees, uint256[] memory shares_) public onlyOwner {
        require(run == 0 ,"this function can be runned once");
        require(payees.length == shares_.length, "Vesting: payees and shares length mismatch");
        require(payees.length > 0, "Vesting: no payees");
         for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(i+1 , payees[i], shares_[i]);
        }
    }
    
    function _addPayee(uint256 id, address account, uint256 shares_) private {

        require(account != address(0), "Vesting: account is the zero address");
        require(shares_ > 0, "Vesting: shares are 0");
        require(_shares[id] == 0, "Vesting: account already has shares");
        require(_exist[id] == false , "Vesting: id already exist");
        
        _indexes[account] = _payees.length;

        _payees.push(account);
        _idToAddress[id] = account;
        _addressToID[account] = id;

        _exist[id] = true;

        _shares[id] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }

   function updateAccount(uint256 id , address account) public onlyOwner{
        require(_exist[id] == true , "Vesting: id already exist");
        
        address previous_address = _idToAddress[id];
        uint256 index = _indexes[_idToAddress[id]];
        //uint256 released = _erc20Released[token][_addressToID[account]];

        _payees[index] = account;
        delete _indexes[_idToAddress[id]] ;
        _indexes[account] = index;

         delete _addressToID[previous_address];
        _idToAddress[id] = account;
        _addressToID[account] = id;
   }
}


