pragma solidity ^0.4.20;

import './SimpleAuctionInterface.sol';

contract SimpleAuction {
    struct Lot {
        string name;
        uint timestamp;
        address owner;
        uint lastBid;
        uint price;
        uint minBid;
        address BestBidder;
        bool completed;      //The Lot is completed if true
        bool processed;      //The Lot is processed if true
    }

    mapping (uint => Lot) public lots;
    mapping (address => uint) public OwnersRatings;
    uint lotNonce = 0;
    uint lifetime = 10000; // Lite time of the Lot

    function createLot(string _name, uint _price, uint _minBid) {
        require (bytes(_name).length != 0 && _price != 0 && _minBid != 0);
        lotNonce++;
        lots[lotNonce] = Lot(_name, block.timestamp, msg.sender, 0, _price, _minBid, msg.sender, false, false);
        OwnersRatings[msg.sender] = 1000;  // Initialisation of owner's rating
    }

    function removeLot(uint _lotID) {
        require (lots[_lotID].lastBid != 0);
        delete (lots[_lotID]);
    }

    function bid(uint _lotID) payable {
        require (lots[_lotID].lastBid < msg.value);
        lots[_lotID].BestBidder.send(lots[_lotID].lastBid);
        lots[_lotID].lastBid = msg.value;
        lots[_lotID].BestBidder = msg.sender;
    }

    function processLot(uint _lotID) {
        require (block.timestamp - lots[_lotID].timestamp > lifetime);
        if (lots[_lotID].lastBid != 0) lots[_lotID].owner.send(lots[_lotID].lastBid);
        lots[_lotID].processed = true;
    }

    function getBidder(uint _lotID) constant returns (address) {
        return (lots[_lotID].BestBidder);
    }

    function isEnded(uint _lotID) constant returns (bool) {
        return (lots[_lotID].completed);
    }

    function isProcessed(uint _lotID) constant returns (bool) {
        return (lots[_lotID].processed);
    }

    function exists(uint _lotID) constant returns (bool) {
        return (bytes(lots[_lotID].name).length != 0);
    }

    function rate(uint _lotID, bool _option) {
        require (lots[_lotID].processed && lots[_lotID].BestBidder == msg.sender && !lots[_lotID].completed);
        address LotOwner = lots[_lotID].owner;
        if (_option) OwnersRatings[LotOwner] += 1; //Uprate the lot owner
            else OwnersRatings[LotOwner] -= 1;  //Downrate the lot owner
        lots[_lotID].completed = true;
    }

    function getRating(address _owner) constant returns (uint) {
        return (OwnersRatings[_owner]);
    }
}
