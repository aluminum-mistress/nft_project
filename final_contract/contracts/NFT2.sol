//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol"; 


contract NFT2 is ERC721{
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public merkleRoot;

    bool public enableMint;
    bool public revealed;
    bool public onlyWhiteListed = true;

    mapping(address => uint256) public addressTotalMintCount;

    string baseURI;

    constructor() ERC721("SOS OSO", "SOSOSO"){
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(_exists(tokenId));
        if(!revealed) {
            return "bit.ly/33U9Q1t";
        }
        string memory revealedBaseURI = _baseURI();
        return bytes(revealedBaseURI).length > 0 ? string(abi.encodePacked(revealedBaseURI, tokenId.toString())): "";
    }

    function preSaleMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable{
        //require(_mintAmount > 0);
        require(onlyWhiteListed);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf));
        require(_tokenIds.current() + _mintAmount <= 2000);
        require(_mintAmount + addressTotalMintCount[msg.sender] <= 2 );
        require(msg.value >= 50000000000000000 * _mintAmount);
        mintloop(_mintAmount);

    }

    function pubSaleMint(uint256 _mintAmount) public payable{
        //require(_mintAmount > 0);
        if(msg.sender != 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            require(!onlyWhiteListed);
            require(_tokenIds.current() + _mintAmount <= 7577);
            require(_mintAmount + addressTotalMintCount[msg.sender] <= 10 );
            require(msg.value >= 80000000000000000 * _mintAmount);
        }else{
            require(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
            require(_mintAmount + addressTotalMintCount[msg.sender] <= 200);
        }
        mintloop(_mintAmount);

    }

    function mintloop(uint256 _mintAmount) internal {
        require(enableMint);
        addressTotalMintCount[msg.sender] = addressTotalMintCount[msg.sender] + _mintAmount;
        for(uint256 i = 1; i <= _mintAmount; i++){
        _safeMint(msg.sender, _tokenIds.current());
        _tokenIds.increment();
        }
    }
    /*
    function pubSaleMint(uint256 _mintAmount) public payable{
        require(enableMint);
        //require(_mintAmount > 0);
        require(!onlyWhiteListed);
        require(_tokenIds.current() + _mintAmount <= 7577);
        require(_mintAmount + addressTotalMintCount[msg.sender] <= 10 );
        require(msg.value >= 80000000000000000 * _mintAmount);
        addressTotalMintCount[msg.sender] = addressTotalMintCount[msg.sender] + _mintAmount;
        for(uint256 i = 1; i <= _mintAmount; i++){
            _safeMint(msg.sender, _tokenIds.current());
            _tokenIds.increment();
        }
    }


    function reserveMint(uint256 _mintAmount) public {
        require(msg.sender == owner);
        require(_mintAmount + addressTotalMintCount[msg.sender] <= 200);
        for(uint256 i = 1; i <= _mintAmount; i++){
            _safeMint(msg.sender, _tokenIds.current());
            _tokenIds.increment();
        }
    }
    


    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    */




    function setEnableMint(bytes32 _merkleRoot, bool _state) external {
        if(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            merkleRoot = _merkleRoot;
            enableMint = _state;
        }
    }


    function reveal(string memory _newBaseURIi) public {
        if(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            revealed = true;
            baseURI = _newBaseURIi;
        }
    }

    function setOnlyWL(bool _state) external {
        if(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            onlyWhiteListed = _state;
        }
    }

    function withdraw(uint256 _amount) external payable {
        if(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            (bool os, ) = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4).call{value: _amount}("");
            require(os);
        }
    }

}