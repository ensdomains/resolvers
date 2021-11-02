pragma solidity ^0.5.0;

import "../ResolverBase.sol";

contract IconNameResolver is ResolverBase {
    bytes4 constant private ICON_INTERFACE_ID = 0xb12a55dd;

    event IconChanged(bytes32 indexed node, bytes icon);

    mapping(bytes32=>bytes) icons;

    /**
     * Sets the icon associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param icon The icon to set.
     */
    function setIcon(bytes32 node, bytes calldata icon) external authorised(node) {
        icons[node] = icon;
        emit IconChanged(node, icon);
    }

    /**
     * Returns the icon associated with an ENS node.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated icon.
     */
    function icon(bytes32 node) external view returns (bytes memory) {
        return icons[node];
    }

    function supportsInterface(bytes4 interfaceID) public pure returns(bool) {
        return interfaceID == ICON_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}
