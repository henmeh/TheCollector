pragma solidity 0.6.2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./TheCollector.sol";
import "./Reward.sol";

contract Marketplace {

    struct Auction {
        uint256 tokenId;
        bool hasStarted;
        uint256 ending;
        uint256 highestBid;
        address highestBidder;
        uint256 index;
    }

    struct Offer {
        uint256 tokenId;
        bool isActive;
        uint256 price;
        uint256 index;
    }
    
    //tokenId => Auctiondata and AuctionList
    mapping(uint256 => Auction) auctionMap;
    Auction[] auctionList;
    
    //tokenId => Offerdata and OfferList
    mapping(uint256 => Offer) offerMap;
    Offer[] offerList;    
    
    address public owner;
    TheCollector collector;
    Reward reward;

    event newAuction(uint256 id, uint256 tokenId, uint256 ending, uint256 highestBid, address highestBidder);
    event newOffer(uint256 id, uint256 tokenId, uint256 price);
    event tokenSold(uint256 id, uint256 tokenId, uint256 price, address buyer);
    event newBid(uint256 id, uint256 tokenId, uint256 bid, address bidder);

    constructor(address _collector, address _reward) public {
        require(address(this) != address(0));
        owner = msg.sender;
        collector = TheCollector(_collector);
        reward = Reward(_reward);
    }

    function setOffer(uint256 _tokenId, uint256 _price) public {
        require(collector.ownerOf(_tokenId) == msg.sender, "Only owner of NFT can make an Offer");
        require(offerMap[_tokenId].isActive == false, "There is already an offer for this NFT");
        require(auctionMap[_tokenId].hasStarted == false, "There is already an Auction for this NFT");
        require(collector.isApprovedForAll(msg.sender, address(this)), "The Marketplace is not approved as operator for your token");

        Offer memory _offer = Offer({
            tokenId: _tokenId,
            isActive: true,
            price: _price,
            index: offerList.length
        });

        offerList.push(_offer);
        offerMap[_tokenId] = _offer;

        emit newOffer(offerMap[_tokenId].index, _tokenId, _price);
    }

    function removeOffer(uint256 _tokenId) public {
        require(collector.ownerOf(_tokenId) == msg.sender, "Only owner of NFT can remove an Offer");
        require(offerMap[_tokenId].isActive == true, "There is no offer for this NFT");

        delete offerMap[_tokenId];
        uint256 _offerId;
        for(_offerId = 0; _offerId < offerList.length; _offerId++){
            if(offerList[_offerId].tokenId == _tokenId) {
                offerList[_offerId].isActive = false;
            }
        }
    }

    function buyNFT(uint256 _tokenId) public payable {
        require(offerMap[_tokenId].isActive == true, "There is no offer for this NFT");
        require(msg.value == offerMap[_tokenId].price, "Please send the correct Price for this NFT");

        uint256 _id = offerMap[_tokenId].index; 
        delete offerMap[_tokenId];
        uint256 _offerId;
        for(_offerId = 0; _offerId < offerList.length; _offerId++){
            if(offerList[_offerId].tokenId == _tokenId) {
                offerList[_offerId].isActive = false;
            }
        }

        collector.approve(msg.sender, _tokenId);
        address payable originalOwner = payable(collector.ownerOf(_tokenId));
        collector.safeTransferFrom(originalOwner, msg.sender, _tokenId); 
        originalOwner.transfer(msg.value);

        //pay reward
        reward.payReward(msg.sender, 1);

        emit tokenSold(_id, _tokenId, msg.value, msg.sender);
    }

    function startAuction(uint256 _tokenId, uint256 _duration) public {
        require(collector.ownerOf(_tokenId) == msg.sender, "Only owner of NFT can start Auction");
        require(auctionMap[_tokenId].hasStarted == false, "Auction already started");
        require(offerMap[_tokenId].isActive == false, "There is an active Sell Offer for this NFT");
        require(collector.isApprovedForAll(msg.sender, address(this)), "The Marketplace is not approved as operator for your token");

        Auction memory _auction = Auction({
            tokenId: _tokenId,
            hasStarted: true,
            ending: now + _duration * 1 minutes,
            highestBid: 0,
            highestBidder: address(0),
            index: auctionList.length
        });

        auctionList.push(_auction);
        auctionMap[_tokenId] = _auction;

        emit newAuction(auctionMap[_tokenId].index, _tokenId, auctionMap[_tokenId].ending, auctionMap[_tokenId].highestBid, auctionMap[_tokenId].highestBidder);
    }
    
    function bid(uint256 _tokenId, uint256 _bid) public {
        require(auctionMap[_tokenId].hasStarted == true, "Auction has not started yet");
        require(_bid >= auctionMap[_tokenId].highestBid, "You need to make an higher offer");
        require(now < auctionMap[_tokenId].ending, "Auction already finished");
     
        auctionMap[_tokenId].highestBid = _bid;
        auctionMap[_tokenId].highestBidder = msg.sender;

        newBid(auctionMap[_tokenId].index, _tokenId, auctionMap[_tokenId].highestBid, auctionMap[_tokenId].highestBidder);
    }
    
    function sellItem(uint256 _tokenId) public payable {
        require(msg.sender == auctionMap[_tokenId].highestBidder, "You did not won the auction");
        require(msg.value == auctionMap[_tokenId].highestBid, "Please send the correct bidding amount");
        require(now > auctionMap[_tokenId].ending, "Auction not finished yet");

        uint256 _id = auctionMap[_tokenId].index;
        delete auctionMap[_tokenId];
        uint256 _auctionId;
        for(_auctionId = 0; _auctionId < auctionList.length; _auctionId++){
            if(auctionList[_auctionId].tokenId == _tokenId) {
                auctionList[_auctionId].hasStarted = false;
            }
        }

        collector.approve(msg.sender, _tokenId);
        address payable originalOwner = payable(collector.ownerOf(_tokenId));
        collector.safeTransferFrom(originalOwner, msg.sender, _tokenId); 
        originalOwner.transfer(msg.value);

        //pay reward
        reward.payReward(msg.sender, 1);

        emit tokenSold(_id, _tokenId, msg.value, msg.sender);
    }

    function deleteAuction(uint256 _tokenId) public {
        require(collector.ownerOf(_tokenId) == msg.sender, "Only owner of NFT can end Auction");
        require(auctionMap[_tokenId].hasStarted == true, "Auction has not started yet");
        require(auctionMap[_tokenId].highestBid == 0 || now > auctionMap[_tokenId].ending + 1500 * 1 minutes, "There is already a bid for the NFT");

        delete auctionMap[_tokenId];
        uint256 _auctionId;
        for(_auctionId = 0; _auctionId < auctionList.length; _auctionId++){
            if(auctionList[_auctionId].tokenId == _tokenId) {
                auctionList[_auctionId].hasStarted = false;
            }    
        }    
    }

//--------------------Some Getter Functions----------------------------------------------------------------

    function getAuctionData(uint256 _tokenId) public view returns(bool, uint256, uint256, address) {
        return (auctionMap[_tokenId].hasStarted, auctionMap[_tokenId].ending, auctionMap[_tokenId].highestBid, auctionMap[_tokenId].highestBidder);
    }

    function getAllActiveAuctions() public returns(uint256[] memory) {
        uint256[] memory _result = new uint256[](auctionList.length);
        uint256 _auctionId;
        for(_auctionId = 0; _auctionId < auctionList.length; _auctionId++){
            if(auctionList[_auctionId].hasStarted == true) {
            _result[_auctionId] = auctionList[_auctionId].tokenId; }
        }
        return _result;
    }

    function getOfferData(uint256 _tokenId) public view returns(bool, uint256) {
        return (offerMap[_tokenId].isActive, offerMap[_tokenId].price);
    }

    function getAllActiveOffers() public returns(uint256[] memory) {
        uint256[] memory _result = new uint256[](offerList.length);
        uint256 _offerId;
        for(_offerId = 0; _offerId < offerList.length; _offerId++){
            if(offerList[_offerId].isActive == true) {
            _result[_offerId] = offerList[_offerId].tokenId; }
        }
        return _result;
    }
}