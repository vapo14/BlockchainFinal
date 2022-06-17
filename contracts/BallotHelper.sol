// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract BallotHelper {

    enum State { Created, Voting, Ended }   // Para ver el estado de la votacion actual
    address public ballotOfficialAddress;   // Para reconocer al oficial
    string public ballotOfficialName;       // Para identificar al oficial
    string public proposal;                 // Para qué se vota
    
    State public state;

    // Modifiers
    modifier condition(bool _condition) {   // Cumple una condicion
        require(_condition);
        _;
    }

    modifier onlyOfficial() {   // Solo el oficial
        require(msg.sender == ballotOfficialAddress);
        _;
    }

    modifier inState(State _state) {    // Para confirmar desde el enum de Stat que este en creado, en proceso, o terminado.
        require(state == _state);
        _;
    }
}