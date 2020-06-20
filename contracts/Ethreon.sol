pragma solidity ^0.5.0;

contract Ethreon {

    // The general structure for a user
    struct People {
        string name;
        address owner;
    }


    // Mapping to get User ID given the public address
    mapping (address => uint) getUserId;
    // Mapping to get all the Creator ID's patron has subscribed to
    mapping (uint => uint[]) getSubscriptions;
    // Array of all patrons on the platform
    People[] public patrons;


    // Mapping to get Creator ID given the public address
    mapping (address => uint) getCreatorId;
    // Mapping to get Creator address given the ID
    mapping (uint => address) getCreatorAddress;
    // Mapping to get all the User ID's who have subscribed to this creator
    mapping (uint => uint[]) getSubscribers;
    // Array of all creators on the platform
    People[] public creators;
    // Mapping of content (Moibit Hash) associated with a creator
    mapping(uint => string) content;


    // Event flagging a new patron
    event NewPatron(uint id, string name);
    // Event flagging a new subscription by a patron
    event NewSubscription(uint id, string cname);
    // Event flagging a new creator
    event NewCreator(uint id, string name);


    // Function to create a new user from the name, public address and return the id
    function newUser (string memory _name) public {
        require(getUserId[msg.sender] == 0, "Address already registered!");
        uint uid = patrons.push(People(_name, msg.sender)) - 1;
        uint[] memory users;
        getSubscriptions[uid] = users;
        getUserId[msg.sender] = uid;
        emit NewPatron(uid, _name);
    }


    // Function to create a new creator from the name, public address and return the id
    function newCreator (string memory _name) public {
        require(getCreatorId[msg.sender] == 0, "Address already registered!");
        uint cid = creators.push(People(_name, msg.sender)) - 1;
        uint[] memory users;
        getSubscribers[cid] = users;
        getCreatorId[msg.sender] = cid;
        getCreatorAddress[cid] = msg.sender;
        string memory cnt;
        content[cid] = cnt;
        emit NewCreator(cid, _name);
    }


    // Function for a patron to subscribe to a creator
    function newSubscription (uint _id) public {
        uint uid = getUserId[msg.sender];
        People memory user = patrons[uid];
        // Check if patron has balance
        require(bytes(creators[_id].name).length > 0, "Not a valid creator!");              // Check validity of creator id
        // Add end validity feature
        getSubscriptions[uid].push(_id);
        getSubscribers[_id].push(uid);
        string memory cname = creators[_id].name;                           // See if anonymity will be better to pitch
        emit NewSubscription(_id, cname);
    }


    // Function to get total number of creators a patron has subscribed to
    function getSubscriptionCount() public view returns (uint) {
        require(getCreatorId[msg.sender] != 0, "Please register first!");
        uint uid = getUserId[msg.sender];
        return getSubscriptions[uid].length;
    }


    // Function to get total number of patrons a creator has been subscribed by
    function getSubscriberCount() public view returns (uint) {
        require(getCreatorId[msg.sender] != 0, "Please register first!");
        uint cid = getCreatorId[msg.sender];
        return getSubscribers[cid].length;
    }


    // Function to return the Moibit hash of content, given a creator id
    function getContent(uint _cid) public view returns (string memory) {
        require(getUserId[msg.sender] != 0, "Please register first!");
        uint uid = getUserId[msg.sender];
        require(getSubscriptionCount() > 0, "Please subscribe to some creator first!");
        bytes memory cnt = bytes(content[_cid]);
        require(cnt.length > 0, "Creater has not posted any content yet! Stay tuned!");
        string memory userContent = content[uid];
        return userContent;
        // Send Moibit hash encrypted with public key
        // When multiple content, serialise string and send - future goal
    }


    // Function which adds a Moibit hash as content linked to creator ID
    function postContent(string memory _ipfsHash) public {
        require(getCreatorId[msg.sender] != 0, "Please register first!");
        uint cid = getCreatorId[msg.sender];
        require(bytes(_ipfsHash).length > 0, "Invalid input hash. Please check IPFS!");
        content[cid] = _ipfsHash;
    }


    // Function to get balance of person
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }


    // // Function to get user data
    // function getUserData() public view returns (People) {
    //     require(getUserId[msg.sender] != 0, "User not found!");
    //     uint uid = getUserId[msg.sender];
    //     People memory user = patrons[uid];
    //     return user;
    // }


    // // Function to get creator data
    // function getCreatorData() public view returns (People) {
    //     require(getCreatorId[msg.sender] != 0, "Creator not found!");
    //     uint cid = getCreatorId[msg.sender];
    //     People memory user = creators[cid];
    //     return user;
    // }


    // Function to tip the creator from the patron
    // function tipCreator(uint _cid) public {
    //     address creatorAdd = getCreatorAddress[_cid];
    //     // Send money here!
    // }
}