// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@1001-digital/erc721-extensions/contracts/RandomlyAssigned.sol";

/// @title Collection NFT Contract
/// @notice Creates an NFT Collection with a library that Randomly assign tokenIDs from a given set of tokens.
/// This contract is not audited, so use at your own risk


contract Collection is ERC721, Ownable, RandomlyAssigned {
    using Strings for uint256;

    uint256 public currentSupply = 0;
    uint256 public limitPerAddress = 5;
    uint256 public cost = 0.01 ether;

    /// You’ll need to upload the metadata files on IPFS or any other platform
    /// and follow the metadata standards https://docs.opensea.io/docs/metadata-standards
    string public baseURI = "ipfs://your-CID/";

    //salva a quantidade de nfts por address
    mapping(address => uint256) public addressMintedBalance;

    /// @notice Instanciate the contract
    /// @param _totalSupply how many tokens this collection should hold
    /// @param _startFrom the tokenID with which to start counting, is good start counting from 1
    /// @param _teamTokens how many tokens the team will get
    constructor(uint256 _totalSupply, uint256 _startFrom, uint256 _teamTokens
    ERC721("collectionName", "SYMBOL")
    RandomlyAssigned(_totalSupply, _startFrom)
    {
        for (uint256 a = 1; a <= _teamTokens; a++) {
            mint(1);
        }
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }

    /// @notice Mint a new Token, owner of this contract can use this function without costs.
    /// @param _mintAmount set the amount of tokens to mint
    function mint (uint256 _mintAmount)
        public
        payable
    {
        require( tokenCount() + 1 <= totalSupply(), "Can't mint more than what's available on collection");
        require( availableTokenCount() - 1 >= 0, "Can't mint more than available token count"); 
        require( tx.origin == msg.sender, "Can't mint through a custom contract");

        if (msg.sender != owner()) {  
        require(msg.value >= cost * _mintAmount, "insufficient funds");
        require(addressMintedBalance[msg.sender] + _mintAmount <= limitPerAddress, "This address already minted the limit permitted.");
        
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
        uint256 id = nextToken();
        addressMintedBalance[msg.sender]++;
        _safeMint(msg.sender, id);
        currentSupply++;
        }
    }

    /// @param tokenId the tokenID number
    /// @return string Metadata Link of TokenId number
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistant token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json"))
        : "";
    }

    /// @notice Owner withdraws the available amount
    function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
    }
