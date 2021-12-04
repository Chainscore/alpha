// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract ChainScoreClient is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;

    event ScoreRequestFulfilled(
        bytes32 indexed requestId,
        uint256 indexed score,
        address indexed user
    );

    address _score = 0x64B60e8C3b8527011B48aD9a19265680FE901CEE;
    address _oracle = 0x3b5544731199d09c5a3686fd87599eDAeA4678B8;

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(_score);
        setChainlinkOracle(_oracle);
    }

    /** ============================= */
    /** ============================= */

    mapping(address => uint256) public scores;
    address[] public logs;

    function requestScore(string memory _address, string memory _jobId)
        public
        onlyOwner
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

        req.add("path", "score");
        req.addInt("times", 100);

        requestOracleData(req, ORACLE_PAYMENT);
    }

    function fulfillScore(
        bytes32 requestId,
        uint256 score,
        address account
    ) public recordChainlinkFulfillment(requestId) {
        emit ScoreRequestFulfilled(requestId, score, account);

        // logs.push(account);
        scores[account] = score;
    }

    /** ============================= */
    /** ============================= */

    function withdrawLink() public onlyOwner {
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
