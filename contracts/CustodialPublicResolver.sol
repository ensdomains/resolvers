pragma solidity ^0.4.24;

import "@ensdomains/ens/contracts/PublicResolver.sol";
import "@dexyproject/signature-validator/contracts/SignatureValidator.sol";

// @todo think of a better name
contract CustodialPublicResolver is PublicResolver {

    bytes32 constant public SET_ADDR_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "address Address",
        "uint256 Nonce"
    );

    bytes32 constant public SET_CONTENT_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "bytes32 Hash",
        "uint256 Nonce"
    );

    bytes32 constant public SET_MULTIHASH_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "bytes Hash",
        "uint256 Nonce"
    );

    bytes32 constant public SET_NAME_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "string Name",
        "uint256 Nonce"
    );

    bytes32 constant public SET_ABI_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "uint256 Content Type",
        "bytes Data",
        "uint256 Nonce"
    );

    bytes32 constant public SET_PUBKEY_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "bytes32 X",
        "bytes32 Y",
        "uint256 Nonce"
    );

    bytes32 constant public SET_TEXT_HASH_SCHEME = keccak256(
        "bytes32 Node",
        "string Key",
        "string Value",
        "uint256 Nonce"
    );

    mapping (bytes32 => bool) public submitted;

    function setAddrOnBehalfOf(bytes32 node, address addr, uint256 nonce, bytes signature) public {
        validateSignature(node, keccak256(SET_ADDR_HASH_SCHEME, keccak256(node, addr, nonce)), signature);
        records[node].addr = addr;
        AddrChanged(node, addr);
    }

    function setContentOnBehalfOf(bytes32 node, bytes32 hash, uint256 nonce, bytes signature) public {

    }

    function setMultihashOnBehalfOf(bytes32 node, bytes hash, uint256 nonce, bytes signature) public {

    }

    function setNameOnBehalfOf(bytes32 node, string name, uint256 nonce, bytes signature) public {

    }

    function setABIOnBehalfOf(bytes32 node, uint256 contentType, bytes data, uint256 nonce, bytes signature) public {

    }

    function setPubkeyOnBehalfOf(bytes32 node, bytes32 x, bytes32 y, uint256 nonce, bytes signature) public {

    }

    function setTextOnBehalfOf(bytes32 node, string key, string value, uint256 nonce, bytes signature) public {

    }

    function validateSignature(bytes32 node, bytes32 hash, bytes signature) private {
        require(!submitted[hash]);
        address signer = SignatureValidator.isValidSignature(hash, signer, signature);
        require(ens.owner(node) == signer);
        submitted[hash] = true;
    }
}
