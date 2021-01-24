pragma solidity ^0.7.4;
import "../ResolverBase.sol";

abstract contract StealthKeyResolver is ResolverBase {
    bytes4 constant private STEALTH_KEY_INTERFACE_ID = 0x69a76591;

    event StealthKeyChanged(bytes32 indexed node, uint256 generationPubKey, uint256 encryptionPubKey);

    struct StealthKey {
        uint256 generationPubKey;
        uint256 encryptionPubKey;
    }

    mapping(bytes32=>StealthKey) _stealthKeys;

    /**
     * Sets the stealth keys associated with an ENS name, for anonymous sends.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param generationPubKey The public key for generating a stealth address
     * @param encryptionPubKey The public key for encrypting the generated address
     */
    function setStealthKeys(bytes32 node, uint256 generationPubKey, uint256 encryptionPubKey) external authorised(node) {
        _stealthKeys[node] = StealthKey(generationPubKey, encryptionPubKey);
        emit StealthKeyChanged(node, generationPubKey, encryptionPubKey);
    }

    /**
     * Returns the stealth key associated with a name.
     * @param node The ENS node to query.
     * @return generationPubKey The public key for generating a stealth address.
     * @return encryptionPubKey The public key for encrypting a stealth address.
     */
    function stealthKeys(bytes32 node) external view returns (uint256 generationPubKey, uint256 encryptionPubKey) {
        StealthKey memory key = _stealthKeys[node];
        return (key.generationPubKey, key.encryptionPubKey);
    }

    function supportsInterface(bytes4 interfaceID) public virtual override pure returns(bool) {
        return interfaceID == STEALTH_KEY_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}
