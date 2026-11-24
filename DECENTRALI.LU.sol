
// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0; 

contract Lutrija2 {

    address payable public admin;
    address public zadnjiPobjednik;

    address payable[] public sudionici;

    uint public iznosListica = 1 ether;

    mapping(address => bool) public prijavljeniSudionik;


    // Konstruktor – postavljanje administratora
    constructor() {
        admin = payable(msg.sender);
    }


    // Dohvat ukupnog iznosa u lutriji
    function iznosIgre() public view returns(uint) {
        return address(this).balance;
    }


    // Dohvat broja sudionika
    function brojSudionika() public view returns(uint) {
        return sudionici.length;
    }


    // Prijava sudionika uplatom Ethera
    receive() external payable {

        require(msg.sender != admin, "Admin ne moze ucestvovati!");

        require(msg.value == iznosListica, "Netocan iznos uplate!");

        require(!prijavljeniSudionik[msg.sender], "Sudionik je vec prijavljen!");

        prijavljeniSudionik[msg.sender] = true;

        sudionici.push(payable(msg.sender));
    }


    // Generiranje nasumicnog broja
    function nasumicanOdabir() private view returns(uint) {

        return uint(keccak256(abi.encodePacked(
            block.prevrandao,
            block.timestamp,
            sudionici.length
        )));
    }


    // Modifier – pristup samo administratoru
    modifier samoAdmin {

        require(msg.sender == admin, "Samo admin moze pokrenuti funkciju!");

        _;
    }


    // Odabir pobjednika i raspodjela sredstava
    function odabirPobjednika() public samoAdmin {

        require(sudionici.length >= 5, "Premalo sudionika");

        uint index = nasumicanOdabir() % sudionici.length;

        address payable pobjednik = sudionici[index];

        zadnjiPobjednik = pobjednik;

        uint iznos = address(this).balance;

        uint adminIznos = iznos / 10;

        uint pobjednikIznos = iznos - adminIznos;

        admin.transfer(adminIznos);

        pobjednik.transfer(pobjednikIznos);


        // Resetiranje statusa sudionika
        for(uint i = 0; i < sudionici.length; i++) {

            prijavljeniSudionik[sudionici[i]] = false;
        }


        // Brisanje liste sudionika
        delete sudionici;
    }
}
