// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract ChainScoreClient is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;

    struct Score {
        uint score;
        uint supply;
        uint value;
        uint debt;
        uint repayment;
    }

    event ScoreRequestFulfilled(
        bytes32 indexed requestId,
        uint256 indexed score,
        uint256 supply_score,
        uint256 value_score,
        uint256 repayment_score,
        uint256 debt_score,
        address indexed user
    );

    mapping(address => Score) public scores;

    bytes32 public jobSpec;

    constructor(address scoreToken, address oracle, bytes32 _jobSpec) ConfirmedOwner(msg.sender) {
        setChainlinkToken(scoreToken);
        setChainlinkOracle(oracle);
        jobSpec = _jobSpec;
    }

    /** ============================= */
    /** ============================= */

    function requestScore(address _address)
        public
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobSpec,
            address(this),
            this.fulfillScore.selector
        );
        req.add("address", toAsciiString(_address));
        sendChainlinkRequest(req, ORACLE_PAYMENT);
    }

    function fulfillScore(
        bytes32 requestId,
        uint256 score,
        uint256 supply_score,
        uint256 value_score,
        uint256 repayment_score,
        uint256 debt_score,
        address account
    ) public recordChainlinkFulfillment(requestId) {

        emit ScoreRequestFulfilled(
            requestId, 
            score, 
            supply_score, 
            value_score, 
            repayment_score, 
            debt_score, 
            account);

        Score storage _score = scores[account];
        _score.score = score;
        _score.supply = supply_score;
        _score.value = value_score;
        _score.repayment = repayment_score;
        _score.debt = debt_score;
    }

    /** ============================= */
    /** ============================= */

    function updateOracle(address _newOracle) external onlyOwner {
        setChainlinkOracle(_newOracle);
    }

    function updateJobSpec(bytes32 _newJobSpec) external onlyOwner {
        jobSpec = _newJobSpec;
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
        public
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

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
