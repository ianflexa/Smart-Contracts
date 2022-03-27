// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Single Image Collection NFT Contract 
/// @notice Creates an NFT Collection where each token has the same image
/// @notice If you want to be a free nft colection, just delete line 20 and line 44
/// This contract is not audited, so use at your own risk

contract SingleImage is ERC721Enumerable, Ownable {
    using Strings for uint256;

    /// You’ll need to upload the metadata files on IPFS or any other platform
    /// and follow the metadata standards https://docs.opensea.io/docs/metadata-standards
    string URI = "ipfs://your-CID/metadata.json"; 
    uint256 public maxSupply = 5;
    uint256 public limitPerAddress = 1;
    uint256 public cost = 0.001 ether;
    bool public paused = false;
    mapping(address => uint256) public addressMintedBalance;

    constructor(
    ) ERC721("Collection Name", "SYMBOL") {
        for(uint256 i = 1; i <= 5; i++) {
            mint();
        }
}


    function _baseURI() internal view virtual override returns (string memory) {
        return URI;
    }

    /// @notice Mint a new Token, owner of this contract can use this function without costs.
    function mint() public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(supply + 1 <= maxSupply, "Can't mint more than available token count");
        require( tx.origin == msg.sender, "Can't mint through a custom contract");

        if(msg.sender != owner()) {
            require(msg.value >= cost, "insufficient funds");
            require(addressMintedBalance[msg.sender] + 1 <= limitPerAddress, "This address already minted the limit permitted.");
        }
        _safeMint(msg.sender, supply + 1);
        addressMintedBalance[msg.sender]++;
    }


    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );
        
            return URI;
    }

    //only owner

    /// @notice Upgrade the available supply of the collection
    /// @param _newmaxSupply value of the new supply for the collection
    function setmaxSupply(uint256 _newmaxSupply) public onlyOwner {
        require (_newmaxSupply > maxSupply, "new max supply lower than the previous one");
        maxSupply = _newmaxSupply;
    }

    /// @notice change the state for access mint function
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
    
    /// @notice Owner withdraws the available amount of this contract
    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

}