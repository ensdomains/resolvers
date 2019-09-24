pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../ResolverBase.sol";

contract AddrResolver is ResolverBase {
    bytes4 constant private ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant private ADDRESS_INTERFACE_ID = 0x0;
    uint constant private COIN_TYPE_ETH = 60;

    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);

    struct AddressInfo {
        uint coinType;
        bytes addr;
    }

    mapping(bytes32=>AddressInfo[]) _addresses;

    /**
     * Sets the address associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param a The address to set.
     */
    function setAddr(bytes32 node, address a) external authorised(node) {
        if(a == address(0)) {
            deleteAddress(node, COIN_TYPE_ETH);
        } else {
            setAddress(node, COIN_TYPE_ETH, addressToBytes(a));
        }
    }

    /**
     * Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) public view returns (address) {
        bytes memory a = addr(node, COIN_TYPE_ETH);
        if(a.length == 0) {
            return address(0);
        }
        return bytesToAddress(a);
    }

    function setAddress(bytes32 node, uint coinType, bytes memory a) public authorised(node) {
        AddressInfo[] storage addrs = _addresses[node];
        emit AddressChanged(node, coinType, a);
        if(coinType == COIN_TYPE_ETH) {
            emit AddrChanged(node, bytesToAddress(a));
        }
        for(uint i = 0; i < addrs.length; i++) {
            if(addrs[i].coinType == coinType) {
                addrs[i].addr = a;
                return;
            }
        }
        addrs.push(AddressInfo(coinType, a));
    }

    function deleteAddress(bytes32 node, uint coinType) public authorised(node) {
        AddressInfo[] storage addrs = _addresses[node];
        for(uint i = 0; i < addrs.length; i++) {
            if(addrs[i].coinType == coinType) {
                if(i < addrs.length - 1) {
                    addrs[i] = addrs[addrs.length - 1];
                }
                addrs.length--;
                emit AddressChanged(node, coinType, "");
                return;
            }
        }
    }

    function addresses(bytes32 node) external view returns(AddressInfo[] memory) {
        return _addresses[node];
    }

    function addr(bytes32 node, uint coinType) public view returns(bytes memory) {
        AddressInfo[] storage addrs = _addresses[node];
        for(uint i = 0; i < addrs.length; i++) {
            if(addrs[i].coinType == coinType) {
                return addrs[i].addr;
            }
        }
        return "";
    }

    function supportsInterface(bytes4 interfaceID) public pure returns(bool) {
        return interfaceID == ADDR_INTERFACE_ID || interfaceID == ADDRESS_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}
