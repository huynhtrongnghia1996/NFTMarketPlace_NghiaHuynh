//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MonoNFT is ERC721URIStorage, ERC721Enumerable {
    constructor() ERC721("MonoNFT", "MONO") { }
    function giveAway(address to) public returns (uint256){
      unit tokenId = _tokenIds.current();

      string memory mockTokenURI = "https://kxwnzsjxs3bf2qwxkoy6zmoknoudqaf2yy6cwb6h4wjbeyuw5saa.arweave.net/VezcyTeWwl1C11Ox7LHKa6g4ALrGPCsHx-WSEmKW7IA";
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, mockTokenURI);
      return tokenId;
    }

function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
 

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

}