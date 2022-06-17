// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./BallotHelper.sol";

contract Ballot is BallotHelper {
    
    // Vars
    struct vote {
        address voterAddress;
        bool choice;
    }

    struct voter {
        string voterName;
        bool voted;
    }

    uint private countResult = 0;   // Privado para contar en progreso
    uint public finalResult = 0;    // Publico para mostrar el resultado final
    uint public totalVoter = 0;     // Cuantos votaron
    uint public totalVote = 0;      // Cuantos votaron positivo



    mapping(uint => vote) private votes;            // 
    mapping(address => voter) public voterRegister; //


    // Event
    event TerminateBallot(address indexed _owner, string _ballotOfficialName, string _proposal, uint _finalResult);

    // Functions
    constructor(
        string memory _ballotOfficialName,
        string memory _proposal        
    ){
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;

        state = State.Created;
    }

    function addVoter(address _voterAddress, string memory _voterName) 
        public
        inState(State.Created)
        onlyOfficial
    {
        voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterRegister[_voterAddress] = v;
        totalVoter++;
    }

    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;

    }

    function doVote(bool _choice)
        public
        inState(State.Voting)
        returns (bool voted) 
    {
        bool found = false;
        // if the voter exists in the registry and has not voted then dovote
        if (bytes(voterRegister[msg.sender].voterName).length != 0 
        && !voterRegister[msg.sender].voted) {
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            if(_choice){
                countResult++;
            }
            votes[totalVote] = v;
            totalVote++;
            found = true;
        }
        return found;
    }

    function endVote()
        public
        inState(State.Voting)
        onlyOfficial
    {
        state = State.Ended;
        finalResult = countResult;
        emit TerminateBallot(msg.sender, ballotOfficialName, proposal, finalResult);
    }

}