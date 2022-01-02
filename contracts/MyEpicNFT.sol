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

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[][3] words;

  constructor() ERC721 ("SquareNFT", "SQUARE") {
    words[0] = ["Blue", "Green", "Red", "Yellow", "Orange", "Purple", "White", "Brown", "Black"];
    words[1] = ["Cat", "Dog", "Panda", "Lion", "Giraffe", "Zebra", "Unicorn", "Rhino", "Manatee", "Capybara", "Boar"];
    words[2] = ["Prancing", "Hopping", "Smiling", "Squatting", "Screaming", "Feasting", "Philosophizing", "Regenerating", "Recuperating"];

    console.log("NFT contract being run/deployed");
  }

  function pickRandomWord(uint256 tokenId, uint8 wordListId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(Strings.toString(block.timestamp), Strings.toString(wordListId), Strings.toString(tokenId))));

    rand = rand % words[wordListId].length;
    return words[wordListId][rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    string[3] memory pickedWords;

    for (uint8 i = 0; i < 3; i++) {
        pickedWords[i] = pickRandomWord(newItemId, i);
    }

    string memory combinedWord = string(abi.encodePacked(pickedWords[0], pickedWords[1], pickedWords[2]));
    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            // We set the title of our NFT as the generated word.
            combinedWord,
            '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
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
  
    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }
}