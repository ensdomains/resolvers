pragma solidity >=0.4.25;

import "./PublicResolver.sol";

contract CustodialPublicResolver is PublicResolver {

    mapping (address => uint256) public nonces;

    /**
     * Sets the address associated with an ENS node on behalf of someone.
     * @param node The node to update.
     * @param addr The address to set.
     * @param signature Signature signed by the node owner.
     */
    function setAddrFor(bytes32 node, address addr, bytes calldata signature) external {
        validateSignature(node, abi.encodePacked(node, addr), signature);
        addresses[node] = addr;
        emit AddrChanged(node, addr);
    }

    /**
     * Sets the contenthash associated with an ENS node on behalf of someone.
     * @param node The node to update.
     * @param hash The contenthash to set.
     * @param signature Signature signed by the node owner.
     */
    function setContenthashFor(bytes32 node, bytes calldata hash, bytes calldata signature) external {
        validateSignature(node, abi.encodePacked(node, hash), signature);
        hashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Sets the name associated with an ENS node, for reverse records on behalf of someone.
     * @param node The node to update.
     * @param name The name to set.
     * @param signature Signature signed by the node owner.
     */
    function setNameFor(bytes32 node, string calldata name, bytes calldata signature) external {
        validateSignature(node, abi.encodePacked(node, name), signature);
        names[node] = name;
        emit NameChanged(node, name);
    }

    /**
     * Sets the ABI associated with an ENS node on behalf of someone.
     * Nodes may have one ABI of each content type. To remove an ABI, set it to
     * the empty string.
     * @param node The node to update.
     * @param contentType The content type of the ABI
     * @param data The ABI data.
     * @param signature Signature signed by the node owner.
     */
    function setABIFor(bytes32 node, uint256 contentType, bytes calldata data, bytes calldata signature) external {
        validateSignature(node, abi.encodePacked(node, contentType, data), signature);

        require(((contentType - 1) & contentType) == 0);

        abis[node][contentType] = data;
        emit ABIChanged(node, contentType);
    }

    /**
     * Sets the SECP256k1 public key associated with an ENS node on behalf of someone.
     * @param node The ENS node to query
     * @param x the X coordinate of the curve point for the public key.
     * @param y the Y coordinate of the curve point for the public key.
     * @param signature Signature signed by the node owner.
     */
    function setPubkeyFor(bytes32 node, bytes32 x, bytes32 y, bytes calldata signature) external {
        validateSignature(node, abi.encodePacked(node, x, y), signature);
        pubkeys[node] = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    /**
     * Sets the text data associated with an ENS node and key on behalf of someone.
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     * @param signature Signature signed by the node owner.
     */
    function setTextFor(bytes32 node, string calldata key, string calldata value, bytes calldata signature) external {
        validateSignature(node, abi.encodePacked(node, key, value), signature);
        texts[node][key] = value;
        emit TextChanged(node, key, key);
    }

    function validateSignature(bytes32 node, bytes memory message, bytes memory signature) private {
        address owner = ens.owner(node);
        uint256 nonce = nonces[owner];

        require(recover(keccak256(abi.encodePacked(message, nonce)), signature) == owner);

        nonces[owner] += 1;
    }

    function recover(bytes32 hash, bytes memory signature) private pure returns (address) {
        uint8 v = uint8(signature[0]);
        bytes32 r;
        bytes32 s;

        assembly {
            r := mload(add(signature, 33))
            s := mload(add(signature, 65))
        }

        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
    }
}
