// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract ElectronicHealthRegistry {

    enum UserRole { ADMIN, DOCTOR, PATIENT}

    struct User {
        bytes16 firstName;
        bytes16 lastName;
        bytes16 personalNumber;
        string personalAddress;
        string emailAddress;
        bytes16 phoneNumber;
        string birthDate;
        uint16 height;
        uint16 weight;
        UserRole privileges;
        bool isUser;
        address[] patients;
    }
    struct Request {
        string description;
        address sender;
        address recipient;
        bool approved;
        uint index;
    }

    

    mapping(address => User) public users;
    address[] public userIndex;
    mapping(address => address) public deployedRegistries;
    mapping (string => Request) private requests;
    mapping (uint => string) private requestIndex;
    uint public requestCount;

    function isRequest(string calldata id) public view returns(bool) {
        if (requestCount == 0) return false;
        return (keccak256(abi.encodePacked(requestIndex[requests[id].index])) == keccak256(abi.encodePacked(id)));
    }

    function createUser(string memory _firstName,
        string memory _lastName,
        string memory _personalNumber,
        string memory _personalAddress,
        string memory _emailAddress,
        string memory _phoneNumber,
        string memory _birthDate,
        uint16 _height,
        uint16 _weight,
        uint8 _role,
        address _requester) public {
            User storage user = users[_requester];
            user.lastName = bytes16(bytes(_lastName));
            user.firstName = bytes16(bytes(_firstName));
            user.personalNumber = bytes16(bytes(_personalNumber));
            user.personalAddress = _personalAddress;
            user.emailAddress = _emailAddress;
            user.phoneNumber = bytes16(bytes(_phoneNumber));
            user.birthDate = _birthDate;
            user.height = _height;
            user.weight = _weight;
            user.isUser = true;

            if(_role == 0) {
                user.privileges = UserRole.ADMIN;
            } else if(_role == 1) {
                user.privileges = UserRole.DOCTOR;  
            } else {
                user.privileges = UserRole.PATIENT;
                createRegistry(_requester);
            }

            userIndex.push(_requester);

    }
    
    function createRegistry(address patient) public {
        require(users[patient].isUser);

        HealthRegistry newRegistry = new HealthRegistry(patient);
        deployedRegistries[patient] = address(newRegistry);
    }

    function createRequest(string calldata description, string calldata id, address recipient)
        public {
            require(!isRequest(id));
            require(users[msg.sender].privileges == UserRole.DOCTOR);
            require(users[recipient].privileges == UserRole.PATIENT);

            Request storage request = requests[id];
            request.description = description;
            request.sender = msg.sender;
            request.recipient = recipient;
            request.approved = false;
            requestIndex[requestCount] = id;
            request.index = requestCount++;

    }

    function retrieveRequestIndex(uint id) public view returns(string memory) {
        return requestIndex[id];
    }

    function retrieveRequest(string calldata id)
        public view returns(string memory, address, address, bool) {
            require(isRequest(id));
            Request storage request = requests[id];
            return (request.description,
                    request.sender,
                    request.recipient,
                    request.approved);
    }

    function approveRequest(uint index) public {
        Request storage r = requests[requestIndex[index]];

        require(r.recipient == msg.sender);
        require(users[r.recipient].privileges == UserRole.PATIENT);
        require(!r.approved);

        r.approved = true;
    
        HealthRegistry he = HealthRegistry(deployedRegistries[msg.sender]);
        he.addDoctor(r.sender);
        users[r.sender].patients.push(msg.sender);
    }


}

contract HealthRegistry {
    struct HealthEntry {
        uint date;
        address doctor;
        uint index;
        uint data;
    }

    address public patient;
    mapping (address => bool) private doctors;
    mapping (string => HealthEntry) private entries;
    mapping (uint => string) private entryIndex;
    uint public entriesCount;

    modifier restricted() {
        require(doctors[msg.sender]);
        _;
    }

    modifier onlyPatient() {
        require(msg.sender == patient);
        _;
    }

    modifier present(string calldata uuid) {
        require(entriesCount > 0);
        require(keccak256(abi.encodePacked(entryIndex[entries[uuid].index])) == keccak256(abi.encodePacked(uuid)));
        _;
    }

    constructor(address person) {
        patient = person;
    }

    function retrieveEntry(string calldata uuid)
        public present(uuid) view returns(uint, uint, address) {
        

        HealthEntry storage he = entries[uuid];     
        return (he.date, he.data, he.doctor);
    }

    function retrieveEntryIndex(uint index)
        public view returns(string memory) {
            return entryIndex[index];
    }

    function createEntry(string calldata uuid, uint data)
        public restricted{
          
        HealthEntry storage he = entries[uuid];
        require(he.date == 0);
        he.date = block.timestamp;
        he.doctor = msg.sender;
        he.data = data;
        entryIndex[entriesCount] = uuid;
        he.index = entriesCount++;
    }


    function updateEntry(string calldata uuid, uint newData)
        public restricted present(uuid) {

        HealthEntry storage he = entries[uuid];
        he.data = newData;
    }

    function deleteEntry(string calldata uuid) public present(uuid) returns(uint) {
        uint oldIndex = entries[uuid].index;
        string storage lastKey = entryIndex[entriesCount-1];
        entryIndex[oldIndex] = lastKey;
        entries[lastKey].index = oldIndex;
        entriesCount--;

        return oldIndex;
    }

    function addDoctor(address doctor) public {
        doctors[doctor] = true;
    }
    
}