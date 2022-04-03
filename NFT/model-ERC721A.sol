// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";



contract ContractExample is ERC721A, Ownable{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MAX_PUBLIC_MINT = 4;
    uint256 public constant MAX_WHITELIST_MINT = 2;
    uint256 public constant PUBLIC_SALE_PRICE = 0.01 ether;
    uint256 public constant WHITELIST_SALE_PRICE = 0.005 ether;
    uint256 public constant TEAM_PART = 30;

    string private  baseTokenUri;
    string public   placeholderTokenUri;

    //deploy smart contract, toggle WL, toggle WL when done, toggle publicSale 
    //2 days later toggle reveal
    bool public isRevealed;
    bool public publicSale;
    bool public whiteListSale;
    bool public pause;
    bool public teamMinted;

    bytes32 private merkleRoot;

    mapping(address => uint256) public totalPublicMint;
    mapping(address => uint256) public totalWhitelistMint;

    constructor() ERC721A("My Collection", "MYC"){

    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Can't mint through a custom contract");
        _;
    }

    function mint(uint256 _quantity) external payable callerIsUser{
        require(publicSale, "Public Sale is not available yet.");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "Can't mint more than what's available on collection");
        require((totalPublicMint[msg.sender] +_quantity) <= MAX_PUBLIC_MINT, "This address already minted the limit permitted.");
        require(msg.value >= (PUBLIC_SALE_PRICE * _quantity), "Insufficient funds");

        totalPublicMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function whitelistMint(bytes32[] memory _merkleProof, uint256 _quantity) external payable callerIsUser{
        require(whiteListSale, "White List is not available yet.");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "Can't mint more than what's available on collection");
        require((totalWhitelistMint[msg.sender] + _quantity)  <= MAX_WHITELIST_MINT, "This address already minted the White List limit permitted.");
        require(msg.value >= (WHITELIST_SALE_PRICE * _quantity), "Insufficient funds");
        //create leaf node
        bytes32 sender = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, sender), "You are not whitelisted");

        totalWhitelistMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function teamMint() external onlyOwner{
        require(!teamMinted, "Team already minted limit permitted");
        teamMinted = true;
        _safeMint(msg.sender, TEAM_PART);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 trueId = tokenId + 1;

        if(!isRevealed){
            return placeholderTokenUri;
        }
        //string memory baseURI = _baseURI();
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }

    function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;
    }
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyOwner{
        placeholderTokenUri = _placeholderTokenUri;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner{
        merkleRoot = _merkleRoot;
    }

    function getMerkleRoot() external view returns (bytes32){
        return merkleRoot;
    }

    function togglePause() external onlyOwner{
        pause = !pause;
    }

    function toggleWhiteListSale() external onlyOwner{
        whiteListSale = !whiteListSale;
    }

    function togglePublicSale() external onlyOwner{
        publicSale = !publicSale;
    }

    function toggleReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }

    function withdraw() external onlyOwner{
        //35% to utility/investors wallet
        uint256 withdrawAmount_35 = address(this).balance * 35/100;
        //20% to artist (post utility)
        uint256 withdrawAmount_20 = (address(this).balance - withdrawAmount_35) * 20/100;
        //5% to advisor (post utility)
        uint256 withdrawAmount_5 = (address(this).balance - withdrawAmount_35) * 5/100;
        payable(0xF70cE6c33687fCB68B823858766Ae515D4928945).transfer(withdrawAmount_35);
        payable(0xC44146197386B2b23c11FFbb37D91a004f5bd829).transfer(withdrawAmount_20);
        payable(0xBD584cE590B7dcdbB93b11e095d9E1D5880B44d9).transfer(withdrawAmount_5);
        payable(msg.sender).transfer(address(this).balance);
    }
}