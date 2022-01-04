// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";


contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string svgPart1 = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><defs><linearGradient id='a' x1='0%' y1='50%' x2='100%' y2='50%'><stop offset='0%' style='stop-color:";
  string svgPart2 = ";stop-opacity:1'/><stop offset='100%' style='stop-color:";
  string svgPart3 = ";stop-opacity:1'/></linearGradient></defs><rect width='100%' height='100%' fill='url(#a)'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' style='fill:#fff;font-family:serif;font-size:24px'>";
  string svgPart4 = "</text></svg>";

  string[][3] words;

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("SquareNFT", "SQUARE") {
    words[0] = ["Blue", "Green", "Red", "Yellow", "Orange", "Purple", "White", "Brown", "Black"];
    words[1] = ["Cat", "Dog", "Panda", "Lion", "Giraffe", "Zebra", "Unicorn", "Rhino", "Manatee", "Capybara", "Boar"];
    words[2] = ["Prancing", "Hopping", "Smiling", "Squatting", "Screaming", "Feasting", "Philosophizing", "Regenerating", "Recuperating"];

    console.log("NFT contract being run/deployed");
  }

  function pickRandomWord(uint256 tokenId, uint256 wordListId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(Strings.toString(block.timestamp), Strings.toString(wordListId), Strings.toString(tokenId))));

    rand = rand % words[wordListId].length;
    return words[wordListId][rand];
  }

  function pickRandomColorCode(uint256 tokenId, uint256 position) public view returns (uint256) {
    uint256 rand = random(string(abi.encodePacked(Strings.toString(block.timestamp), Strings.toString(position), Strings.toString(tokenId))));
    return rand % 256;
  }

  function getRandomColor(uint256 tokenId, uint256 index) public view returns (string memory) {
    string memory redVal = Strings.toString(pickRandomColorCode(tokenId, index*3 + 1));
    string memory greenVal = Strings.toString(pickRandomColorCode(tokenId, index*3 + 2));
    string memory blueVal = Strings.toString(pickRandomColorCode(tokenId, index*3 + 3));

    return string(abi.encodePacked('rgb(', redVal, ',', greenVal, ',', blueVal, ')'));
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    require(newItemId < 11, "Maximum of ten NFTs can be minted in this collection");

    string[3] memory pickedWords;

    for (uint8 i = 0; i < 3; i++) {
        pickedWords[i] = pickRandomWord(newItemId, i);
    }

    string memory combinedWord = string(abi.encodePacked(pickedWords[0], pickedWords[1], pickedWords[2]));
    string memory color1 = getRandomColor(newItemId, 1);
    string memory color2 = getRandomColor(newItemId, 2);

    string memory finalSvg = string (abi.encodePacked(svgPart1, color1, svgPart2, color2, svgPart3, combinedWord, svgPart4));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            // We set the title of our NFT as the generated word.
            combinedWord,
            '", "description": "Randomly-generated NFTs", "image": "data:image/svg+xml;base64,',
            // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
            Base64.encode(bytes(finalSvg)),
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(combinedWord);
    console.log(
      string(
        abi.encodePacked(
          "https://nftpreview.0xdev.codes/?code=",
            finalTokenUri
          )
        )
    );
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, finalTokenUri);
  
    emit NewEpicNFTMinted(msg.sender, newItemId);

    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }
}