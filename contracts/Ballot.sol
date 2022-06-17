// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

// importar contrato helper con modificadores
import "./BallotHelper.sol";

contract Ballot is BallotHelper {
    
    // Variables 
    struct vote {
        address voterAddress;
        bool choice;
    }

    struct voter {
        string voterName;
        bool voted;
    }

    uint private countResult = 0;   // Variable privada, solo se incrementa por voto
    uint public finalResult = 0;    // Variable publica, solo se modifica al terminar la votacion
    uint public totalVoter = 0;     // Personas que se han registrado
    uint public totalVote = 0;      // Cuantas personas votaron a favor.



    mapping(uint => vote) private votes;            // mapa para registrar los votos, el numero de voto apunta al voto
    mapping(address => voter) public voterRegister; // mapa de registro de votos, la direccion apunta al que vota


    // Event
    // evento que se ejecuta al terminar la votacion, registra el dueno, el nombre de la boleta, la propuesta a votar y el resultado final
    event TerminateBallot(address indexed _owner, string _ballotOfficialName, string _proposal, uint _finalResult);

    // Functions
    constructor(
        // recibe el nombre boleta
        string memory _ballotOfficialName,
        // recibe la propuesta a votar
        string memory _proposal        
    ){
        // el dueno oficial de la boleta
        ballotOfficialAddress = msg.sender;
        // el nombre oficial de la boleta
        ballotOfficialName = _ballotOfficialName;
        // la propuesta
        proposal = _proposal;


        // el estado de la votacion
        state = State.Created;
    }

    /**
        funcion de agregar votante
        recibe la direccion 
     */
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