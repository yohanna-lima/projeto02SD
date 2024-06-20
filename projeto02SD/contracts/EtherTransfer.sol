// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ContratoCadastroEstudantes {
    
    struct Estudante {
        string nomeEstudante;
        uint idade;
        bool preRequisito;
        bool matriculado;
    }

    mapping(address => Estudante) private _estudantesMatriculados;
    address payable public empresa;

    event EstudanteMatriculado(address indexed estudanteAddress, string nome);

    constructor(address payable _empresa) {
        empresa = _empresa;
    }

    function matricularEstudante(string memory _nomeEstudante, uint _idade, bool _preRequisito) public payable {
        require(msg.value > 0, "Necessario enviar ether para matricula");
        require(!_estudantesMatriculados[msg.sender].matriculado, "Estudante ja matriculado");
        require(ehNomeValido(_nomeEstudante), "O nome precisa ser informado"); 
        require(ehIdadeValida(_idade), "A idade precisa ser informada"); 
        require(_preRequisito, "O estudante precisa ter o pre-requisito"); 

        Estudante memory estudante = Estudante(_nomeEstudante, _idade, _preRequisito, true); // Atualizei para marcar como matriculado
        _estudantesMatriculados[msg.sender] = estudante;

        emit EstudanteMatriculado(msg.sender, _nomeEstudante);

        empresa.transfer(msg.value);
    }

    function getEstudante(address _estudanteAddress) public view returns (string memory, uint, bool) {
        Estudante memory estudante = _estudantesMatriculados[_estudanteAddress];
        return (estudante.nomeEstudante, estudante.idade, estudante.preRequisito);
    }

    function ehIdadeValida(uint _idadeEstudante) private pure returns (bool) { 
        return _idadeEstudante > 0;
    }

    function ehNomeValido(string memory _nomeEstudante) private pure returns (bool) { 
        bytes memory tempString = bytes(_nomeEstudante); 
        return tempString.length > 0; 
    }

    function transferirEther() public {
        require(msg.sender == empresa, "Somente a empresa pode chamar esta funcao");
        empresa.transfer(address(this).balance);
    }
}
