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

        // the phases of the election (state machine)
    enum Phase {Registration, Voting, Ended }

    // current phase, starts as Registration
    Phase public phase;

    // events: messages saved in the transaction log
    event CandidateAdded(uint256 candidateId, string name);
    event VoterValidated(address voter);
    event VotingStarted();
    event VoteCast(address voter, uint256 candidateId);
    event VotingEnded();

    // runs only once, when the contract is launched
    constructor() {

        admin = msg.sender;  // whoever launches the contract becomes the admin

    }

        // only the admin can call the function
    modifier onlyAdmin() {

        require(msg.sender == admin, "Only the admin can do this");
        _;
    }

    // only a validated voter can call the function
    modifier onlyValidatedVoter() {

        require(isValidated[msg.sender], "You aren't a valid voter");
        _;

    }

    // admin adds a new candidate with 0 votes

    function addCandidate(string memory name) public onlyAdmin {

        require(phase == Phase.Registration, "Registration phase is finished");
        candidates.push(Candidate(name, 0));
        emit CandidateAdded(candidates.length - 1, name);

    }

    // admin validates an address as an eligible voter
     function validateVoter(address voter) public onlyAdmin {

        require(phase == Phase.Registration, "Registration phase  is finished");
        require(!isValidated[voter], "Voter was already validated");
        isValidated[voter] = true;
        emit VoterValidated(voter);


    }

        // admin opens the voting
    function startVoting() public onlyAdmin {

        require(phase == Phase.Registration, "Voting has already started");
        require(candidates.length >= 2, "At least two candidates are needed");
        phase = Phase.Voting;
        emit VotingStarted();

    }

    //validated voter votes onnce for a candidate
    function vote(uint256 candidateId) public  onlyValidatedVoter {

        require(isValidated[msg.sender], "You aren't a valid voter");
        require(!hasVoted[msg.sender], "You have already voted");
        require(candidateId < candidates.length, "Invalid candidate ID.");

        hasVoted[msg.sender] = true;              // mark the voter first
        candidates[candidateId].voteCount += 1;   // counts the vote
        emit VoteCast(msg.sender, candidateId);

    }

    // admin closes the voting
    function endVoting() public onlyAdmin {

        require(phase == Phase.Voting, "Voting hasn't started yet");
        phase = Phase.Ended;
        emit VotingEnded();

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

        // returns the current phase (0 = Registration, 1 = Voting, 2 = Ended)
    function getPhase() public view returns (Phase) {

        return phase;

    }

    // returns the candidate with the most votes
    // if there is a tie tie, the first one added wins
    function declareWinner() public view returns (string memory, uint256) {

        require(phase == Phase.Ended, "Voting hasn;t finished yet");
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