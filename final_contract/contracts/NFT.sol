//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol"; 
import "./ERC2981.sol";

contract NFT is ERC721, ERC721URIStorage, ERC2981, ERC165Storage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public merkleRoot;
    address public owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    bool public enableMint;
    bool public onlyWhiteListed = true;

    mapping(address => uint256) public addressTotalMintCount;


    
    constructor() ERC721("PolarBearSkiClub", "PBSC") {
        _registerInterface(0x80ac58cd);
        _registerInterface(0x2a55205a);
    }

    function mint(uint256 _mintAmount, bytes32[] calldata _merkleProof) external payable{
        require(_mintAmount > 0);
        if(msg.sender != owner){
            require(enableMint);
            if(onlyWhiteListed){
                bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
                require(MerkleProof.verify(_merkleProof, merkleRoot, leaf));

                require(_tokenIds.current() + _mintAmount <= 2000);
                require(_mintAmount <= 2 - addressTotalMintCount[msg.sender]);
                require(msg.value >= 50000000000000000 * _mintAmount);
            }else{
                require(_tokenIds.current() + _mintAmount <= 7777 - 200);
                require(_mintAmount <= 10 - addressTotalMintCount[msg.sender]);
                require(msg.value >= 80000000000000000 * _mintAmount);
            }
        }else{
            require(_mintAmount <= 200);
            require(addressTotalMintCount[msg.sender] <= 200);
        }
        
        for(uint256 i = 1; i <= _mintAmount; i++){
            addressTotalMintCount[msg.sender]++;
            _safeMint(msg.sender, _tokenIds.current());
            _setTokenURI(_tokenIds.current(), "www.mystery/json");
            _setRoyalties(_tokenIds.current(), owner, 10);
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

    function setEnableMint(bytes32 _merkleRoot, bool _state) external {
        if(msg.sender == owner){
            merkleRoot = _merkleRoot;
            enableMint = _state;
        }
    }

    function setOnlyWL(bool _state) external {
        if(msg.sender == owner){
            onlyWhiteListed = _state;
        }
    }

    function adjustTokenURI(uint256 _tokenID, string memory _URI) external  {
        if(msg.sender == owner){
        _setTokenURI(_tokenID, _URI);
        }
    }

    function adjustTokenURIBatch(string memory _URLCID) external {
        if(msg.sender == owner){
            for(uint256 i = 0 ; i < _tokenIds.current(); i++){
                //https://ipfs.io/ipfs/CID/i
                _setTokenURI(i, string(abi.encodePacked(_URLCID,toString(i))));
            }
        }
    }    

    function withdraw(uint256 _amount) external payable {
        if(msg.sender == owner){
            (bool os, ) = payable(owner).call{value: _amount}("");
            require(os);
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC165Storage, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}