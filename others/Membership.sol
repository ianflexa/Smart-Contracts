// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract Memberships is  ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Conters.Counter;
    using Strings for uint256;
    // TODO local where you storage data
    string _baseTokenURI = "ipfs://your-CID/";
    // TODO choice the price of membershisp
    uint256 private _price = 0.1 ether;

    // TODO for team
    uint256 public constant RESERVED_FOUNDING_MEMBERS = 10;
    uint256 public constant FOUNDING_MEMBERS_SUPPLY = 100;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _subscriptionCounter;

    // store price and duration of membership

    struct SubscripitonPlan {
        uint256 price;
        uint256 duration;
    }

    // available plans
    mapping (uint256 => SubscripitonPlan) subscripitonPlans;

    // store the time of an address membership
    mapping (address => uint256) subscriptionExpiration;

    event Mint(address indexed _minterMember, uint256tokenId);
    event Subscription(address _subscrMember, SubscripitonPlan Plan, uint256 timestamp, uint256 expireAt, uint subscriptionCounter);
    
    constructor() ERC721("Your Memberships", "SYMBOL") {
        //you can set here how many subcription plans you want
        subscripitonPlans[0] = SubscripitonPlan(0.15 ether, 30 days);
        subscripitonPlans[1] = SubscripitonPlan(0.4 ether, 90 days);
        subscripitonPlans[2] = SubscripitonPlan(1 ether, 365 days);

        for(uint i = 0; i < RESERVED_FOUNDING_MEMBERS; i++){
            _safeMint(msg.sender);
        }
    }

    // owner can edit and add a subscription plan
    function updateSubscriptionPlan(uint256 index, SubscriptionPlan memory plan) public onlyOnwer {
        subscripitonPlans[index] = plan;
    }

    function _getSubscriptionPlan(uint256 index) private view returns(SubscripitonPlan memory) {
        SubscripitonPlan memory plan = subscripitonPlans[index];

        require(plan.duration > 0, "Subscription plan does not exist");
        return plan;
    }

    function getSubscriptionPlan(uint256 index) external view returns(SubscriptionPlan memory) {
        return _getSubscriptionPlan(index);
    }

    function subscribe(address _to, uint256 planIndex)whenNotPaused public payable {
        SubscriptionPlan memory plan = _getSubscriptionPlan(planIndex);

        require(plan.price == msg.value, "wrong amount sent");
        require(plan.duration > 0, "Subscription plan does not exist");
        // current time   
        uint256 startingDate = block.timestamp;
        // check if _to address already has a sub active
        if(_hasActiveSubscription(_to)) {
            startingDate = subscriptionExpiration[_to];
        }
        // set the expiry date
        uint256 expiresAt = startingDate + plan.duration;

        // save the expiry date of the _to on the map 
        subscriptionExpiration[_to] = expiresAt;
        _subscriptionCounter.increment();

        emit Subscription(_to, plan, block.timestamp, expiresAt, _subscriptionCounter.current());
    }

    // will return true if the address was active
    // will return 0 if the address never had a subscription
    function _hasActiveSubscription(address _address) private view returns(bool) {
        return subscriptionExpiration[_address] > block.timestamp;
    }

    function hasActiveSubscription(address _address) external view returns(bool) {
        return _hasActiveSubscription(_address);
    }

    function mint(address _to) whenNotPaused public payable {
        require(msg.value >= _price, "Insuficient funds");
        require(_tokenIdCounter.current() < FOUNDING_MEMBERS_SUPPLY, "Can't mint over supply limit");

        require(BalanceOf(_to) == 0, "Can't mint more than one membership");

        _tokenIdCounter.increment();

        _safeMint(_to, _tokenIdCounter.current());
        emit Mint(_to, _tokenIdCounter.current());
    }

    function getBalance() external view returns (uint256) {
        return _price;
    }

    function setPrice(uint256 price) public OnlyOwner {
        _price = price;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function _baseURI() internal override view returns(string memory) {
        return _baseTokenURI;
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function _safeMint(address to) public onlyOwner {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function hasFoundingMemberToken (address wallet) public view returns(bool){
        return balanceOf(wallet) > 0;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns(bool) {
        return super.supportsInterface(interfaceId);
    }
}