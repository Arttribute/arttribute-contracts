// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AIArtNFT.sol";

contract AIArtCompetition is Ownable {
    struct Competition {
        uint256 endTime;
        uint256 prizeAmount;
        address prizeTokenAddress; // Address of the ERC20 token to be used as prize. If address is 0x0, prize is in native currency (e.g., ETH)
        address[] voters;
        uint256[] submissions;
        bool isActive;
    }

    AIArtNFT public aiArtNft;
    uint256 public competitionId;
    mapping(uint256 => Competition) public competitions;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Mapping to track if a voter has voted in a competition
    mapping(uint256 => mapping(uint256 => uint256)) public votes; // Mapping from competition ID to submission ID to vote count

    event CompetitionCreated(uint256 indexed competitionId, uint256 endTime, uint256 prizeAmount, address prizeTokenAddress);
    event ArtSubmitted(uint256 indexed competitionId, uint256 indexed submissionId);
    event Voted(uint256 indexed competitionId, uint256 indexed submissionId, address voter);
    event WinnerAnnounced(uint256 indexed competitionId, uint256 winnerSubmissionId, uint256 prizeAmount);

    constructor(address aiArtNftAddress) {
        aiArtNft = AIArtNFT(aiArtNftAddress);
    }

    function createCompetition(uint256 _endTime, uint256 _prizeAmount, address _prizeTokenAddress, address[] memory _voters) external onlyOwner {
        require(_endTime > block.timestamp, "End time must be in the future");
        competitionId++;
        competitions[competitionId] = Competition({
            endTime: _endTime,
            prizeAmount: _prizeAmount,
            prizeTokenAddress: _prizeTokenAddress,
            voters: _voters,
            submissions: new uint256[](0),
            isActive: true
        });
        emit CompetitionCreated(competitionId, _endTime, _prizeAmount, _prizeTokenAddress);
    }

    function submitArt(uint256 _competitionId, uint256 _artId) external {
        require(competitions[_competitionId].isActive, "Competition is not active");
        require(block.timestamp < competitions[_competitionId].endTime, "Competition submission period has ended");
        competitions[_competitionId].submissions.push(_artId);
        emit ArtSubmitted(_competitionId, _artId);
    }

    function vote(uint256 _competitionId, uint256 _submissionId) external {
        require(competitions[_competitionId].isActive, "Competition is not active");
        require(isVoter(_competitionId, msg.sender), "Caller is not a voter");
        require(!hasVoted[_competitionId][msg.sender], "Caller has already voted");
        require(block.timestamp > competitions[_competitionId].endTime, "Voting is not yet open");
        votes[_competitionId][_submissionId]++;
        hasVoted[_competitionId][msg.sender] = true;
        emit Voted(_competitionId, _submissionId, msg.sender);
    }

    function announceWinner(uint256 _competitionId) external onlyOwner {
        require(competitions[_competitionId].isActive, "Competition is not active");
        require(block.timestamp > competitions[_competitionId].endTime, "Competition is not yet concluded");
        competitions[_competitionId].isActive = false;

        uint256 winnerSubmissionId = determineWinner(_competitionId);
        // Implement prize distribution logic here
        // For simplicity, this logic is not included in this example
        emit WinnerAnnounced(_competitionId, winnerSubmissionId, competitions[_competitionId].prizeAmount);
    }

    function isVoter(uint256 _competitionId, address _voter) public view returns (bool) {
        for (uint256 i = 0; i < competitions[_competitionId].voters.length; i++) {
            if (competitions[_competitionId].voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    function determineWinner(uint256 _competitionId) internal view returns (uint256 winnerSubmissionId) {
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < competitions[_competitionId].submissions.length; i++) {
            uint256 submissionId = competitions[_competitionId].submissions[i];
            uint256 submissionVotes = votes[_competitionId][submissionId];
            if (submissionVotes > maxVotes) {
                maxVotes = submissionVotes;
                winnerSubmissionId = submissionId;
            }
        }
    }
}
