pragma solidity ^0.8.0;

contract Election {
    address public owner;
    enum State {NOT_STARTED, ONGOING, ENDED}
    State public electionState;
    uint public candidateCount;
    uint public voterCount;

    struct Candidate {
        string name;
        string proposal;
        uint id;
        uint voteCount;
    }

    struct Voter {
        address voterAddress;
        string name;
        uint votedFor;
        bool hasVoted;
        bool voteDelegated;
        address delegate;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;

    event NewCandidateAdded(string name, string proposal, uint id);
    event NewVoterAdded(address voterAddress, string name);
    event VoteCast(address indexed voter, uint candidateId);
    event VoteDelegated(address indexed from, address indexed to);
    event ElectionStarted();
    event ElectionEnded();
    event WinnerAnnounced(string name, uint id, uint voteCount);

    constructor() {
        owner = msg.sender;
        electionState = State.NOT_STARTED;
        candidateCount = 0;
        voterCount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyDuringElection() {
        require(electionState == State.ONGOING, "Election is not ongoing");
        _;
    }

    modifier onlyBeforeElection() {
        require(electionState == State.NOT_STARTED, "Election has already started");
        _;
    }

    modifier onlyAfterElection() {
        require(electionState == State.ENDED, "Election has not yet ended");
        _;
    }
}