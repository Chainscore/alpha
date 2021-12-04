// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WaitList is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _waitlistedCount;

    mapping(uint => address) public waitlist;
    mapping(address => bool)  public _hasRegistered;
    mapping(address => uint) public referCount;

    uint max;
    uint registrationClose;

    event NewRegistration(address _user);

    constructor(uint _max, uint _registrationClose) {
        max = _max;
        registrationClose = _registrationClose;
    }

    modifier onlyWhenActive(){
        require(_waitlistedCount.current() < max, "Max registrations reached");
        require(block.timestamp < registrationClose, "Registration Closed");
        _;
    }

    function register(address _referrer) external onlyWhenActive {
        require(!hasRegistered(msg.sender), "Already Registered");
        require(hasRegistered(_referrer), "Invalid referrer");
        waitlist[_waitlistedCount.current()] = msg.sender;
        _waitlistedCount.increment();
        referCount[_referrer] += 1;
        emit NewRegistration(msg.sender);
    }

    function hasRegistered(address  _user) public view returns(bool){
        return _hasRegistered[_user];
    }

    function updateCloseTime(uint _newCloseTime) external onlyOwner {
        registrationClose = _newCloseTime;
    }

    function updateMax(uint _newMax) external onlyOwner {
        max = _newMax;
    }
}