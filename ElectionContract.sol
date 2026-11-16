// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Election Contract - V1
// admin (Election Authority) adds candidates and validates voters
// each validated voter can vote once and the contract counts the votes automatically

contract ElectionContract {

    // election autorithy
    address public admin;

    // groups the data of one candidate
    struct Candidate {
        string name;        // candidate name
        uint256 voteCount;  // number of votes received
    }

    // list of candidates
    //each candidate's ID is its position in the list
    Candidate[] public candidates;

    // true = the admin validated this address as an eligible voter
    mapping(address => bool) public isValidated;

    // true = this address already voted
    mapping(address => bool) public hasVoted;

    // runs only once, when the contract is launched
    constructor() {

        admin = msg.sender;  // whoever launches the contract becomes the admin

    }

    // admin adds a new candidate with 0 votes
    function addCandidate(string memory name) public {

        require(msg.sender == admin, "Only admin can add candidates");

        candidates.push(Candidate(name, 0));

    }

    // admin validates an address as an eligible voter
    function validateVoter(address voter) public {

        require(msg.sender == admin, "Only admin can validate voters");
        require(!isValidated[voter], "Voter was already validated");
        isValidated[voter] = true;


    }
    //validated voter votes onnce for a candidate
    function vote(uint256 candidateId) public {

        require(isValidated[msg.sender], "You aren't a valid voter");
        require(!hasVoted[msg.sender], "You have already voted");
        require(candidateId < candidates.length, "Invalid candidate ID.");

        hasVoted[msg.sender] = true;              // mark the voter first
        candidates[candidateId].voteCount += 1;   // counts the vote

    }

    // returns the name and vote count of a candidate

    function getCandidate(uint256 id) public view returns (string memory, uint256) {

        require(id < candidates.length, "Invalid candidate ID");
        return (candidates[id].name, candidates[id].voteCount);

    }

    // returns how many candidates are registered
    function getCandidatesCount() public view returns (uint256) {

        return candidates.length;

    }

    // returns the candidate with the most votes
    // if there is a tie tie, the first one added wins
    function declareWinner() public view returns (string memory, uint256) {

        require(candidates.length > 0, "There are no candidates");

        uint256 winnerId = 0;

        for (uint256 i = 1; i < candidates.length; i++) {

            if (candidates[i].voteCount > candidates[winnerId].voteCount) {

                winnerId = i;

            }

        }

        return (candidates[winnerId].name, candidates[winnerId].voteCount);

    }    

}