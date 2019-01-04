pragma solidity >=0.4.25;

contract DNSResolver {

    address public owner;
    mapping (bytes32 => bytes) zones;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setDnsrr(bytes32 node, bytes memory data) public onlyOwner {
        zones[node] = data;
    }

    function dnsrr(bytes32 node) public view returns (bytes memory) {
        return zones[node];
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x126a710e;
    }
}
