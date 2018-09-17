pragma solidity ^0.4.24;

import "./PublicResolver.sol";
import "@dexyproject/signature-validator/contracts/SignatureValidator.sol";

contract CustodialPublicResolver is PublicResolver {

    mapping (address => uint256) public nonce;

    function setAddrFor(bytes32 node, address addr, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, addr), signature);
        records[node].addr = addr;
        emit AddrChanged(node, addr);
    }

    function setContentFor(bytes32 node, bytes32 hash, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, hash), signature);
        records[node].content = hash;
        emit ContentChanged(node, hash);
    }

    function setMultihashFor(bytes32 node, bytes hash, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, hash), signature);
        records[node].multihash = hash;
        emit MultihashChanged(node, hash);
    }

    function setNameFor(bytes32 node, string name, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, name), signature);
        records[node].name = name;
        emit NameChanged(node, name);
    }

    function setABIFor(bytes32 node, uint256 contentType, bytes data, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, contentType, data), signature);

        require(((contentType - 1) & contentType) == 0);

        records[node].abis[contentType] = data;
        emit ABIChanged(node, contentType);
    }

    function setPubkeyFor(bytes32 node, bytes32 x, bytes32 y, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, x, y), signature);
        records[node].pubkey = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    function setTextFor(bytes32 node, string key, string value, bytes signature) public {
        validateSignature(node, abi.encodePacked(node, key, value), signature);
        records[node].text[key] = value;
        emit TextChanged(node, key, key);
    }

    function validateSignature(bytes32 node, bytes message, bytes signature) private {
        address owner = ens.owner(node);
        uint256 nonce = nonce[owner];

        bytes32 hash = keccak256(abi.encodePacked(message, nonce));
        address signer = SignatureValidator.isValidSignature(hash, signature);

        require(ens.owner(node) == signer);
        nonce[owner] += 1; // @todo SafeMath
    }
}
