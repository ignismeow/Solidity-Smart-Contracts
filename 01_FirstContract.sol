// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //stating our version

contract SimpleStorage{
    //favorite number get initialized to 0 if no value is given to it.
    uint256 myFavoriteNumber; //internal & storage variable

    // uint256[] listofFavoriteNumbers;
    struct Person{
        uint256 favoriteNumber;
        string name;
    }

    // dynamic array
    Person[] public listOfPeople;
   
    // Chelsa -> 253
    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public{
        myFavoriteNumber = _favoriteNumber;
    }

    // view, pure
    function retrieve() public  view returns (uint256){
        return myFavoriteNumber;
    }

    // calldata, memory, storage
    function addPerson (string memory _name, uint256 _favoriteNumber) public {
        listOfPeople.push( Person(_favoriteNumber, _name) );
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}
