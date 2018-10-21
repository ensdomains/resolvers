pragma solidity ^0.4.24;

import "./PublicResolver.sol";

contract CustodialPublicResolver is PublicResolver {

    mapping (address => uint256) public nonces;

    constructor(ENS ens) public PublicResolver(ens) { }

    /**
     * Sets the address associated with an ENS node on behalf of someone.
     * @param node The node to update.
     * @param addr The address to set.
     * @param signature Signature signed by the node owner.
     */
    function setAddrFor(bytes32 node, address addr, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, addr), signature);
        records[node].addr = addr;
        emit AddrChanged(node, addr);
    }

    /**
     * Sets the content hash associated with an ENS node on behalf of someone.
     * Note that this resource type is not standardized, and will likely change
     * in future to a resource type based on multihash.
     * @param node The node to update.
     * @param hash The content hash to set.
     * @param signature Signature signed by the node owner.
     */
    function setContentFor(bytes32 node, bytes32 hash, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, hash), signature);
        records[node].content = hash;
        emit ContentChanged(node, hash);
    }

    /**
     * Sets the multihash associated with an ENS node on behalf of someone.
     * @param node The node to update.
     * @param hash The multihash to set.
     * @param signature Signature signed by the node owner.
     */
    function setMultihashFor(bytes32 node, bytes hash, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, hash), signature);
        records[node].multihash = hash;
        emit MultihashChanged(node, hash);
    }

    /**
     * Sets the name associated with an ENS node, for reverse records on behalf of someone.
     * @param node The node to update.
     * @param name The name to set.
     * @param signature Signature signed by the node owner.
     */
    function setNameFor(bytes32 node, string name, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, name), signature);
        records[node].name = name;
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
    function setABIFor(bytes32 node, uint256 contentType, bytes data, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, contentType, data), signature);

        require(((contentType - 1) & contentType) == 0);

        records[node].abis[contentType] = data;
        emit ABIChanged(node, contentType);
    }

    /**
     * Sets the SECP256k1 public key associated with an ENS node on behalf of someone.
     * @param node The ENS node to query
     * @param x the X coordinate of the curve point for the public key.
     * @param y the Y coordinate of the curve point for the public key.
     * @param signature Signature signed by the node owner.
     */
    function setPubkeyFor(bytes32 node, bytes32 x, bytes32 y, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, x, y), signature);
        records[node].pubkey = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    /**
     * Sets the text data associated with an ENS node and key on behalf of someone.
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     * @param signature Signature signed by the node owner.
     */
    function setTextFor(bytes32 node, string key, string value, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, key, value), signature);
        records[node].text[key] = value;
        emit TextChanged(node, key, key);
    }

    function validateSignature(bytes32 node, bytes message, bytes signature) private {
        address owner = ens.owner(node);
        uint256 nonce = nonces[owner];

        require(recover(keccak256(abi.encodePacked(message, nonce)), signature) == owner);

        nonces[owner] += 1;
    }

    function recover(bytes32 hash, bytes signature) private returns (address) {
        uint8 v = uint8(signature[0]);
        bytes32 r;
        bytes32 s;

        assembly {
            r := mload(add(signature, 33))
            s := mload(add(signature, 65))
        }

        return ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s);
    }
}
