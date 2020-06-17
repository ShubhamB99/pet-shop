pragma solidity ^0.5.0;

contract PatreonDatabase {

    struct People {
        string name;
        address owner;
    }

    mapping (address => uint) getUserId;
    mapping (uint => uint[]) getSubscriptions;
    People[] public patrons;

    function _createNewPatron (string memory _name) internal returns (uint) {
        uint id = patrons.push(People(_name, msg.sender)) - 1;
        uint[] memory users;
        getSubscriptions[id] = users;
        return id;
    }

    mapping (address => uint) getCreatorId;
    mapping (uint => uint[]) getSubscribers;
    People[] public creators;

    function _createNewCreator (string memory _name) internal returns (uint) {
        uint id = creators.push(People(_name, msg.sender)) - 1;
        uint[] memory users;
        getSubscribers[id] = users;
        return id;
    }
}

contract Patron is PatreonDatabase {

    event NewPatron(uint id, string name);
    event NewSubscription(uint id, string cname);

    function newUser (string memory _name) public {
        require(getUserId[msg.sender] == 0, "Address already registered!");
        uint uid = _createNewPatron(_name);
        getUserId[msg.sender] = uid;
        emit NewPatron(uid, _name);
    }

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

    function getSubscriptionCount() public view returns (uint) {
        require(getCreatorId[msg.sender] != 0, "Please register first!");
        uint uid = getUserId[msg.sender];
        return getSubscriptions[uid].length;
    }
}

contract Creator is PatreonDatabase {

    event NewCreator(uint id, string name);

    mapping(uint => string[]) content;

    function newCreator (string memory _name) public {
        require(getCreatorId[msg.sender] == 0, "Address already registered!");
        uint cid = creators.push(People(_name, msg.sender)) - 1;
        getUserId[msg.sender] = cid;
        string[] memory cnt;
        content[cid] = cnt;
        emit NewCreator(cid, _name);
    }

    function getSubscriberCount() public view returns (uint) {
        require(getCreatorId[msg.sender] != 0, "Please register first!");
        uint cid = getCreatorId[msg.sender];
        return getSubscribers[cid].length;
    }
}

contract Ethreon is Patron, Creator {

    // function getContent(uint _cid) public view returns (string[] memory) {
    //     require(getUserId[msg.sender] != 0, "Please register first!");
    //     uint uid = getUserId[msg.sender];
    //     require(getSubscriptionCount() > 0, "Please subscribe to some creator first!");
    //     require(bytes(content[_cid][0]).length > 0, "Creater has not posted any content yet! Stay tuned!");
    //     string[] memory userContent = content[uid];
    //     //Serialise string and send
    //     return userContent;

    //     // Send IPFS hash encrypted with public key
    // }

    function postContent(string memory _ipfsHash) public {
        require(getCreatorId[msg.sender] != 0, "Please register first!");
        uint cid = getCreatorId[msg.sender];
        require(bytes(_ipfsHash).length > 0, "Invalid input hash. Please check IPFS!");
        content[cid].push(_ipfsHash);
    }

}