pragma solidity ^0.5.0;

import "../ResolverBase.sol";

contract ContentHashResolver is ResolverBase {
    bytes4 constant private CONTENT_HASH_INTERFACE_ID = 0xbc1c58d1;
    bytes4 constant private MULTI_CONTENT_HASH_INTERFACE_ID = 0x6de03e07;

    event ContenthashChanged(bytes32 indexed node, bytes hash);

    mapping(bytes32=>mapping(bytes=>bytes)) hashes;

    /**
     * Sets the default contenthash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param hash The contenthash to set.
     */
    function setContenthash(bytes32 node, bytes calldata hash) external authorised(node) {
        hashes[node][''] = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Sets the contenthash with specific type associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param proto The contenthash protoCode to set.
     * @param hash The contenthash to set.
     */
    function setContenthash(bytes32 node, bytes calldata proto, bytes calldata hash) external authorised(node) {
        hashes[node][proto] = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Returns the default contenthash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) external view returns (bytes memory) {
        return hashes[node][''];
    }

    /**
     * Returns the contenthash with specific type associated with an ENS node.
     * @param node The ENS node to query.
     * @param proto The contenthash protoCode to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node, bytes calldata proto) external view returns (bytes memory) {
        return hashes[node][proto];
    }

    function supportsInterface(bytes4 interfaceID) public pure returns(bool) {
        return interfaceID == CONTENT_HASH_INTERFACE_ID || interfaceID == MULTI_CONTENT_HASH_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}
