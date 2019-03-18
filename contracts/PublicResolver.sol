pragma solidity ^0.5.0;

import "@ensdomains/ens/contracts/ENS.sol";
import "./profiles/ABIResolver.sol";
import "./profiles/AddrResolver.sol";
import "./profiles/ContentHashResolver.sol";
import "./profiles/InterfaceResolver.sol";
import "./profiles/NameResolver.sol";
import "./profiles/PubkeyResolver.sol";
import "./profiles/TextResolver.sol";

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract PublicResolver is ABIResolver, AddrResolver, ContentHashResolver, InterfaceResolver, NameResolver, PubkeyResolver, TextResolver {
    ENS ens;

    constructor(ENS _ens) public {
        ens = _ens;
    }

    function isAuthorised(bytes32 node) internal view returns(bool) {
        return ens.owner(node) == msg.sender;
    }
}
