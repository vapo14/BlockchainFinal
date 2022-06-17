// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./BallotHelper.sol"; /// importar contrato helper con modificadores

/*
 * @author Gerardo Granados y Victor Padron
 * @dev Maneja votaciones aseguradas con direcciones de Ethereum
 */
contract Ballot is BallotHelper {
    struct vote {
        address voterAddress;
        bool choice;
    }

    struct voter {
        string voterName;
        bool voted;
    }

    uint256 private countResult = 0; /// Variable privada, solo se incrementa por voto
    uint256 public finalResult = 0; /// Variable publica, solo se modifica al terminar la votacion
    uint256 public totalVoter = 0; /// Personas que se han registrado
    uint256 public totalVote = 0; /// Cuantas personas votaron a favor.

    mapping(uint256 => vote) private votes; /// mapa para registrar los votos, el numero de voto apunta al voto
    mapping(address => voter) public voterRegister; /// mapa de registro de votos, la direccion apunta al que vota

    /// evento que se ejecuta al terminar la votacion, registra el dueno, el nombre de la boleta, la propuesta a votar y el resultado final
    event TerminateBallot(
        address indexed _owner,
        string _ballotOfficialName,
        string _proposal,
        uint256 _finalResult
    );

    constructor(
        /// recibe el nombre boleta
        string memory _ballotOfficialName,
        /// recibe la propuesta a votar
        string memory _proposal
    ) {
        /// el dueno oficial de la boleta
        ballotOfficialAddress = msg.sender;
        /// el nombre oficial de la boleta
        ballotOfficialName = _ballotOfficialName;
        /// la propuesta
        proposal = _proposal;

        /// el estado de la votacion
        state = State.Created;
    }

    /*
     * @dev agrega votante que tiene permiso de votar.
     * @param _voterAddress: address con la direccion del votante.
     * @param _voterName: string con el nombre del votante.
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
        totalVoter++; /// Aumenta el total de votantes posibles.
    }

    /*
     * @dev Cambia el estado a Voting para empezar a coleccionar votos.
     */
    function startVote() public inState(State.Created) onlyOfficial {
        state = State.Voting;
    }

    /*
     * @dev Confirma que el votante puede votar, registra su voto y aumenta los votos ejecutados.
     * @param _choice: bool con la decision del votante.
     */
    function doVote(bool _choice)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;
        /// if the voter exists in the registry and has not voted then dovote
        if (
            bytes(voterRegister[msg.sender].voterName).length != 0 &&
            !voterRegister[msg.sender].voted
        ) {
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            if (_choice) {
                countResult++;
            }
            votes[totalVote] = v;
            totalVote++;
            found = true;
        }
        return found;
    }

    /*
     * @dev Cambia el estado a Ended para dejar de coleccionar votos.
     */
    function endVote() public inState(State.Voting) onlyOfficial {
        state = State.Ended;
        finalResult = countResult;
        emit TerminateBallot(
            msg.sender,
            ballotOfficialName,
            proposal,
            finalResult
        );
    }
}
