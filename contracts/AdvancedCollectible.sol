//NFT where the tokenURI can be one of 3 different dogs
// randomly selected
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    uint256 public tokenCounter;
    bytes32 public keyhash;
    uint256 public fee;
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => address) public requestIdToSender;
    // a good practice is to emit an event every time
    // a mapping is updated:
    event requestedCollectible(bytes32 indexed requestId, address requester);
    event breedAssigned(uint256 indexed tokenId, Breed breed);

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyhash,
        uint256 _fee
    )
        public
        VRFConsumerBase(_vrfCoordinator, _linkToken)
        ERC721("Dogie", "DOG")
    {
        tokenCounter = 0;
        keyhash = _keyhash;
        fee = _fee;
    }

    function createCollectible() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyhash, fee); // will create a random number for a random breed for our dog
        requestIdToSender[requestId] = msg.sender;
        emit requestedCollectible(requestId, msg.sender);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        Breed breed = Breed(randomNumber % 3);
        // now we need to assign the random breed to a token Id with a mapping
        uint256 newTokenId = tokenCounter;
        tokenIdToBreed[newTokenId] = breed;
        emit breedAssigned(newTokenId, breed);
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        tokenCounter = tokenCounter + 1;
    }

    // override means that only the VF coordinator can call the function
    // IDEALLY, we want to make it even more decentralized by having the VRF fulfillRandomness function
    // be the one picking up the tokenURI

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        // one tokenURI per dog/img
        // we want that only the owner of tokenID can update the tokenURI
        // we will call a Open Zepplein function called _isApprovedOrOwner which checks
        // the owner of a tokenId/approval status to mingle with the tokenURI
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}
