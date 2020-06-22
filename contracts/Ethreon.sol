pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import './SafeMath.sol';
import './EthreonBase.sol';

contract Ethreon is Patron, Creator {

    // Structure to store subscribers and their end date
    struct SubscribersData {
        address patronAddress;
        uint endSubscription;
    }

    // Mapping to get all the patrons subscribed to creator
    mapping (address => SubscribersData[]) Subscribers;
    // Event flagging new subscription to highlight creator
    event NewSubscription(address _creator);

    // Event flagging addition of creator image
    event ImageAdded();
    // Event flagging addition of content by creator
    event ContentAdded();

    // Function for patron to subscribe to new creator
    function newSubscription(address _creator) public isPatronRegistered {
        require(alreadyRegisteredCreator[_creator], "Not a registered creator!");
        Subscriptions[msg.sender].push(_creator);
        Subscribers[_creator].push(SubscribersData(msg.sender, now + 30 days));
        emit NewSubscription(_creator);
    }

    // Function to add image for the creator
    function addCreatorImage(string memory _imageHash) public isCreatorRegistered {
        require(bytes(_imageHash).length > 0, "Not a valid image hash!");
        CreatorData[msg.sender].imageHash = _imageHash;
        emit ImageAdded();
    }

    // Function to add content by the creator
    function addCreatorContent(string memory _contentHash) public isCreatorRegistered {
        require(bytes(_contentHash).length > 0, "Not a valid image hash!");
        CreatorData[msg.sender].contentHash = _contentHash;
        emit ContentAdded();
    }

    // Function to return string of content hash to registered patron
    function getContent(address _creator) public view isPatronRegistered returns (string memory ) {
        require(alreadyRegisteredCreator[_creator], "Not a registered creator!");
        // require(Subscribers[_creator].isValue, "No subscribers of this creator yet!");
        SubscribersData[] memory users = Subscribers[_creator];
        for (uint i = 0; i < users.length; i++) {
            if (users[i].patronAddress == msg.sender) {
                if (users[i].endSubscription > now) {
                    return CreatorData[_creator].contentHash;
                }
            }
        }
        return "";                // Should never reach here ideally
    }
}