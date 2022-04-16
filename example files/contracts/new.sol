// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "./ERC2981.sol";
import { Base64 } from "./libraries/Base64.sol";



contract mint is ERC721, ERC721URIStorage, ERC2981, ERC165Storage, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using Strings for uint256;
    
    event NewNFTMinted(address sender, uint256 tokenId);

    uint256 public mintFees = 0.05 ether;
    uint256 public maxSupply = 7000;
    uint256 private maxMintAmount = 2;
    uint256 private maxTotalMintLimit = 2;
    uint256 private royaltyPermill = 10;

    bool private enableMint = false;
    bool private onlyWhiteListed = true;

    address[] public whitelistedAddresses;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_IERC2981 = 0x2a55205a;
    bytes4 private constant _INTERFACE_ID_PaymentSplitter = 0x4a7f18f2;

    constructor() ERC721("Test", "TEST") {
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_IERC2981);
    }

    function publicmint(uint256 _mintAmount) public payable{

        require(enableMint, "Mint not active.");
        uint256 supply = _tokenIds.current();
        require(_mintAmount > 0, "Can't Mint 0.");
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if(msg.sender != owner()){
            if(onlyWhiteListed == true){
                require(isWhitelisted(msg.sender),"You are not on the whitelist!");
                uint256 ownerTokenCount = balanceOf(msg.sender);
                require(ownerTokenCount < maxTotalMintLimit);
            }
            require(msg.value >= mintFees * _mintAmount);
        }

        for(uint256 i = 1; i <= _mintAmount; i++){

            _safeMint(msg.sender, supply + i);
            
            string memory json = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "#',
                            toString(supply + i),
                            '", "description": "test lol", "image": "https://nft-starter-project.taiyanglyu.repl.co/Upload/blind_box.png'
                        )
                    )
                )
            );

            string memory finalTokenURI = string(abi.encodePacked("data:application/json;base64,", json));
            

            _setTokenURI(supply + i,"Hi");
            _setRoyalties(supply + i, owner(), royaltyPermill);
            emit NewNFTMinted(msg.sender, supply+i);

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

    function isWhitelisted(address _user) public view returns (bool){
      for(uint256 i = 0; i < whitelistedAddresses.length; i++){
          if(whitelistedAddresses[i] == _user){
              return true;
          }
        }
      return false;
    }

    function adjustTokenURI(uint256 _tokenID, string memory _URILocation) public onlyOwner {
        _setTokenURI(_tokenID, _URILocation);
    }    

    function setMintFees(uint256 _newMintFees) public onlyOwner {
        mintFees = _newMintFees;
    }

    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        mintFees = _newMaxSupply;
    }    

    function setMaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setMaxTotalMintLimit(uint256 _limit) public onlyOwner {
        maxTotalMintLimit = _limit;
    }
    
    function setRoyaltyPermill(uint256 _newRoyaltyPermill) public onlyOwner {
        royaltyPermill = _newRoyaltyPermill;
    }

    function setEnableMint(bool _state) public onlyOwner {
        enableMint = _state;
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhiteListed = _state;
    }

    function addWhitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
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