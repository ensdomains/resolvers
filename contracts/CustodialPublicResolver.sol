pragma solidity ^0.4.24;

import "./PublicResolver.sol";
import "@dexyproject/signature-validator/contracts/SignatureValidator.sol";

contract CustodialPublicResolver is PublicResolver {

    mapping (address => uint256) public nonce;

    function setAddrFor(bytes32 node, address addr, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, addr, nonce), signature);
        records[node].addr = addr;
        emit AddrChanged(node, addr);
    }

    function setContentFor(bytes32 node, bytes32 hash, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, hash, nonce), signature);
        records[node].content = hash;
        emit ContentChanged(node, hash);
    }

    function setMultihashFor(bytes32 node, bytes hash, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, hash, nonce), signature);
        records[node].multihash = hash;
        emit MultihashChanged(node, hash);
    }

    function setNameFor(bytes32 node, string name, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, name, nonce), signature);
        records[node].name = name;
        emit NameChanged(node, name);
    }

    function setABIFor(bytes32 node, uint256 contentType, bytes data, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, contentType, data, nonce), signature);

        require(((contentType - 1) & contentType) == 0);

        records[node].abis[contentType] = data;
        emit ABIChanged(node, contentType);
    }

    function setPubkeyFor(bytes32 node, bytes32 x, bytes32 y, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, x, y, nonce), signature);
        records[node].pubkey = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    function setTextFor(bytes32 node, string key, string value, uint256 nonce, bytes signature) public {
        validateSignature(node, nonce, keccak256(node, key, value, nonce), signature);
        records[node].text[key] = value;
        emit TextChanged(node, key, key);
    }

    function validateSignature(bytes32 node, uint256 nonce, bytes32 hash, bytes signature) private {
        address signer = SignatureValidator.isValidSignature(hash, signer, signature);
        require(nonce[signer] == nonce);
        require(ens.owner(node) == signer);
        nonce[signature] += 1; // @todo SafeMath
    }
}
