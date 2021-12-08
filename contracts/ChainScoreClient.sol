// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ChainScoreClient is ChainlinkClient, ConfirmedOwner, AccessControl {
    using Chainlink for Chainlink.Request;

    bytes32 constant public WHITELISTED_USER = keccak256("WHITELISTED_USER");
    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;

    event ScoreRequestFulfilled(
        bytes32 indexed requestId,
        uint256 indexed score,
        string indexed user
    );

    mapping(string => uint256) public scores;
    mapping(string => uint256) public supply_scores;
    mapping(string => uint256) public value_scores;
    mapping(string => uint256) public repayment_scores;
    mapping(string => uint256) public debt_scores;

    constructor(address scoreToken, address oracle) ConfirmedOwner(msg.sender) {
        setChainlinkToken(scoreToken);
        setChainlinkOracle(oracle);
        grantRole(WHITELISTED_USER, msg.sender);
    }

    /** ============================= */

    function requestScore(string memory _address, string memory _jobId)
        public
        onlyRole(WHITELISTED_USER)
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillScore.selector
        );
        bytes memory str = abi.encodePacked(
            "http://169.60.167.178:3001/score/",
            _address
        );
        string memory url = string(str);

        req.add("get", url);
        req.add("address", _address);
        req.addInt("times", 10**18);

        requestOracleData(req, ORACLE_PAYMENT);
    }

    function fulfillScore(
        bytes32 requestId,
        uint256 score,
        uint256 supply_score,
        uint256 value_score,
        uint256 repayment_score,
        uint256 debt_score,
        string memory account
    ) public recordChainlinkFulfillment(requestId) {
        emit ScoreRequestFulfilled(requestId, score, account);

        scores[account] = score;
        supply_scores[account] = supply_score;
        value_scores[account] = value_score;
        repayment_scores[account] = repayment_score;
        debt_scores[account] = debt_score;
    }

    /** ============================= */

    function whitelistUser(address user) public onlyOwner {
        grantRole(WHITELISTED_USER, user);
    }

    function whitelistUsers(address[] memory users) external onlyOwner {
        for(uint i = 0; i<users.length; i++){
            whitelistUser(users[i]);
        }
    }

    function updateOracle(address _newOracle) external onlyOwner {
        setChainlinkOracle(_newOracle);
    }

    function updateScoreToken(address _newToken) external onlyOwner {
        setChainlinkToken(_newToken);
    }

    function withdrawScore() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
