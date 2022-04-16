// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./modules/PaymentSplitter.sol";


import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";//convert to base64

contract MyEpicNFT is ERC721, ERC721URIStorage, ERC165Storage, Ownable, PaymentSplitter {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;//count token ids

  event NewEpicNFTMinted(address sender, uint256 tokenId);//monitor if user has mint new nft

  

  constructor() ERC721 ("Test 30/21/2021", "TEST") {

    _registerInterface(_INTERFACE_ID_PaymentSplitter);

  }

  //convert uint256 to string
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
  
  uint256 private mintFees;
  uint256 private mintSize;
  
  bytes4 private constant _INTERFACE_ID_PaymentSplitter = 0x4a7f18f2;

  
  event UpdatedMintFees(uint256 _old, uint256 _new);
  event UpdatedMintSize(uint _old, uint _new);

  //mint nft function
  function makeAnEpicNFT(uint amount) public payable {


    uint256 newItemId = _tokenIds.current();

    //metadata string in json to base64
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "#',
                    // name is the token id
                    toString(newItemId),
                    '", "description": "test lol", "image": "https://nft-starter-project.taiyanglyu.repl.co/Upload/',
                    toString(newItemId),
                    '.jpg"}'
                )
            )
        )
    );

    //json address to tokenURI
    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));
    
    console.log(finalTokenUri);

    require(msg.value == mintFees * amount, "Wrong amount of Native Token");
    
    for (uint i = 0; i < amount; i++) {
      _safeMint(msg.sender, newItemId);
      _tokenIds.increment();
    }

    //set URI, id and URI in json
    _setTokenURI(newItemId, "hi");
    //add 1 increment to token ids
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    emit NewEpicNFTMinted(msg.sender, newItemId);//end monitor
  }

  function setMintFees(uint256 _newFee) public onlyOwner {
    uint256 oldFee = mintFees;
    mintFees = _newFee;
    emit UpdatedMintFees(oldFee, mintFees);
  }
  function setMintSize(uint256 _amount) public onlyOwner {
    uint256 old = mintSize;
    mintSize = _amount;
    emit UpdatedMintSize(old, mintSize);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC165Storage) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function addPayee(address addy, uint256 shares) public onlyOwner {
    _addPayee(addy, shares);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
  }
  
  function _baseURI() internal pure override returns (string memory) {
    return "ipfs://";
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

}