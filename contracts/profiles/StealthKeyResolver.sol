pragma solidity ^0.7.4;
import "../ResolverBase.sol";

abstract contract StealthKeyResolver is ResolverBase {
    bytes4 constant private STEALTH_KEY_INTERFACE_ID = 0x69a76591;

    event StealthKeyChanged(bytes32 indexed node, uint256 spendingPubKeyPrefix, uint256 spendingPubKey, uint256 viewingPubKeyPrefix, uint256 viewingPubKey);

    // node => prefix => key
    mapping(bytes32 => mapping(uint256 => uint256)) _stealthKeys;

    /**
     * Sets the stealth keys associated with an ENS name, for anonymous sends.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param spendingPubKeyPrefix Prefix of the spending public key (2 or 3)
     * @param spendingPubKey The public key for generating a stealth address
     * @param viewingPubKeyPrefix Prefix of the viewing public key (2 or 3)
     * @param viewingPubKey The public key to use for encryption
     */
    function setStealthKeys(bytes32 node, uint256 spendingPubKeyPrefix, uint256 spendingPubKey, uint256 viewingPubKeyPrefix, uint256 viewingPubKey) external authorised(node) {
        require(
            (spendingPubKeyPrefix == 2 || spendingPubKeyPrefix == 3) &&
            (viewingPubKeyPrefix == 2 || viewingPubKeyPrefix == 3),
            "StealthKeyResolver: Invalid Prefix"
        );

        delete _stealthKeys[node][0];
        delete _stealthKeys[node][1];
        delete _stealthKeys[node][2];
        delete _stealthKeys[node][3];

        _stealthKeys[node][spendingPubKeyPrefix - 2] = spendingPubKey;
        _stealthKeys[node][viewingPubKeyPrefix] = viewingPubKey;

        emit StealthKeyChanged(node, spendingPubKeyPrefix, spendingPubKey, viewingPubKeyPrefix, viewingPubKey);
    }

    /**
     * Returns the stealth key associated with a name.
     * @param node The ENS node to query.
     * @return spendingPubKeyPrefix Prefix of the spending public key (2 or 3)
     * @return spendingPubKey The public key for generating a stealth address
     * @return viewingPubKeyPrefix Prefix of the viewing public key (2 or 3)
     * @return viewingPubKey The public key to use for encryption
     */
    function stealthKeys(bytes32 node) external view returns (uint256 spendingPubKeyPrefix, uint256 spendingPubKey, uint256 viewingPubKeyPrefix, uint256 viewingPubKey) {
        if (_stealthKeys[node][0] != 0) {
            spendingPubKeyPrefix = 2;
            spendingPubKey = _stealthKeys[node][0];
        } else {
            spendingPubKeyPrefix = 3;
            spendingPubKey = _stealthKeys[node][1];
        }

        if (_stealthKeys[node][2] != 0) {
            viewingPubKeyPrefix = 2;
            viewingPubKey = _stealthKeys[node][2];
        } else {
            viewingPubKeyPrefix = 3;
            viewingPubKey = _stealthKeys[node][3];
        }

        return (spendingPubKeyPrefix, spendingPubKey, viewingPubKeyPrefix, viewingPubKey);
    }

    function supportsInterface(bytes4 interfaceID) public virtual override pure returns(bool) {
        return interfaceID == STEALTH_KEY_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}
