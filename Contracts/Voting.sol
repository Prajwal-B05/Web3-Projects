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

    function addCandidate(string memory _name, string memory _proposal) public onlyBeforeElection onlyOwner {
        candidateCount++;
        candidates[candidateCount] = Candidate(_name, _proposal, candidateCount, 0);
        emit NewCandidateAdded(_name, _proposal, candidateCount);
    }

    function addVoter(address _voter, string memory _name) public onlyBeforeElection onlyOwner {
        require(voters[_voter].voterAddress == address(0), "Voter already added");
        voterCount++;
        voters[_voter] = Voter(_voter, _name, 0, false, false, address(0));
        emit NewVoterAdded(_voter, _name);
    }
     function startElection() public onlyOwner onlyBeforeElection {
        electionState = State.ONGOING;
        emit ElectionStarted();
    }

    function displayCandidateDetails(uint _id) public view returns (uint id, string memory name, string memory proposal) {
        Candidate memory candidate = candidates[_id];
        id = candidate.id;
        name = candidate.name;
        proposal = candidate.proposal;
    }

  function showWinner() public onlyAfterElection  returns (string memory name, uint id, uint voteCount) {
    uint winningVoteCount = 0;
    uint winningCandidateId;
    for (uint i = 1; i <= candidateCount; i++) {
        if (candidates[i].voteCount > winningVoteCount) {
            winningVoteCount = candidates[i].voteCount;
            winningCandidateId = i;
        }
    }
    Candidate memory winningCandidate = candidates[winningCandidateId];
    name = winningCandidate.name;
    id = winningCandidate.id;
    voteCount = winningVoteCount;
    emit WinnerAnnounced(name, id, voteCount);
}
function vote(uint _candidateId) public onlyDuringElection {
    Voter storage voter = voters[msg.sender];
    require(!voter.hasVoted, "You have already voted");
    require(voter.voteDelegated == false, "You have delegated your vote");

    Candidate storage candidate = candidates[_candidateId];
    require(candidate.id != 0, "Candidate does not exist");

    voter.hasVoted = true;
    voter.votedFor = _candidateId;
    candidate.voteCount++;

    emit VoteCast(msg.sender, _candidateId);
}
function endElection() public onlyOwner onlyDuringElection {
    electionState = State.ENDED;
    emit ElectionEnded();
}

function displayWinner() public onlyAfterElection  returns (string memory) {
    (string memory name, uint id, uint voteCount) = showWinner();
    return string(abi.encodePacked("Winner: ", name, " (ID: ", uint2str(id), ", Vote Count: ", uint2str(voteCount), ")"));
}

// Helper function to convert a uint to a string
function uint2str(uint _i) internal pure returns (string memory str) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint length;
    while (j != 0) {
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length;
    while (_i != 0) {
        k = k-1;
        uint8 temp = (48 + uint8(_i - _i / 10 * 10));
        bytes1 b1 = bytes1(temp);
        bstr[k] = b1;
        _i /= 10;
    }
    return string(bstr);
}


function delegateVote(address _to) public onlyDuringElection {
    Voter storage sender = voters[msg.sender];
    require(!sender.hasVoted, "You have already voted");
    require(!sender.voteDelegated, "You have already delegated your vote");

    // Ensure delegate is not the sender
    require(_to != msg.sender, "You cannot delegate your vote to yourself");

    // Follow the chain of delegates until a non-delegated voter is found
    while (voters[_to].voteDelegated) {
        _to = voters[_to].delegate;
        require(_to != msg.sender, "Delegation loop detected");
    }

    // Assign delegate to the sender and mark vote as delegated
    sender.voteDelegated = true;
    sender.delegate = _to;

    // If the delegate has already voted, add the vote to the candidate
    Voter storage delegateTo = voters[_to];
    if (delegateTo.hasVoted) {
        candidates[delegateTo.votedFor].voteCount++;
        emit VoteCast(msg.sender, delegateTo.votedFor);
    } else {
        // If the delegate has not voted, forward the vote to the delegate
        emit VoteDelegated(msg.sender, _to);
    }
}
}