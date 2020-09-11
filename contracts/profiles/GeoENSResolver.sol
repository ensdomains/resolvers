pragma solidity ^0.5.0;

import "../ResolverBase.sol";

contract GeoENSResolver is ResolverBase {
    bytes4 constant ERC2390 = 0x8fbcc5ce;
    uint constant MAX_ADDR_RETURNS = 64;
    uint constant TREE_VISITATION_QUEUESZ = 64;
    uint8 constant ASCII_0 = 48;
    uint8 constant ASCII_9 = 57;
    uint8 constant ASCII_a = 97;
    uint8 constant ASCII_b = 98;
    uint8 constant ASCII_i = 105;
    uint8 constant ASCII_l = 108;
    uint8 constant ASCII_o = 111;
    uint8 constant ASCII_z = 122;

    struct Node {
        address data; // 0 if not leaf
        uint256 parent;
        uint256[] children; // always length 32
    }

    // A geohash is 8, base-32 characters.
    // A geomap is stored as tree of fan-out 32 (because
    // geohash is base 32) and height 8 (because geohash
    // length is 8 characters)
    mapping(bytes32=>Node[]) private geomap;

    event GeoENSRecordChanged(bytes32 indexed node, bytes8 geohash, address addr);

    // only 5 bits of ret value are used
    function chartobase32(byte c) pure internal returns (uint8 b) {
        uint8 ascii = uint8(c);
        require( (ascii >= ASCII_0 && ascii <= ASCII_9) ||
                (ascii > ASCII_a && ascii <= ASCII_z));
        require(ascii != ASCII_a);
        require(ascii != ASCII_i);
        require(ascii != ASCII_l);
        require(ascii != ASCII_o);

        if (ascii <= (ASCII_0 + 9)) {
            b = ascii - ASCII_0;

        } else {
            // base32 b = 10
            // ascii 'b' = 0x60
            // note base32 skips the letter 'a'
            b = ascii - ASCII_b + 10;

            // base32 also skips the following letters
            if (ascii > ASCII_i)
                b --;
            if (ascii > ASCII_l)
                b --;
            if (ascii > ASCII_o)
                b --;
        }
        require(b < 32); // base 32 cant be larger than 32
        return b;
    }

    function geoAddr(bytes32 node, bytes8 geohash, uint8 precision) external view returns (address[] memory ret) {
        bytes32(node); // single node georesolver ignores node
        assert(precision <= geohash.length);

        ret = new address[](MAX_ADDR_RETURNS);
        if (geomap[node].length == 0) { return ret; }
        uint ret_i = 0;

        // walk into the geomap data structure
        uint pointer = 0; // not actual pointer but index into geomap
        for(uint8 i=0; i < precision; i++) {

            uint8 c = chartobase32(geohash[i]);
            uint next = geomap[node][pointer].children[c];
            if (next == 0) {
                // nothing found for this geohash.
                // return early.
                return ret;
            } else {
                pointer = next;
            }
        }

        // pointer is now node representing the resolution of the query geohash.
        // DFS until all addresses found or ret[] is full.
        // Do not use recursion because blockchain...
        uint[] memory indexes_to_visit = new uint[](TREE_VISITATION_QUEUESZ);
        indexes_to_visit[0] = pointer;
        uint front_i = 0;
        uint back_i = 1;

        while(front_i != back_i) {
            Node memory cur_node = geomap[node][indexes_to_visit[front_i]];
            front_i ++;

            // if not a leaf node...
            if (cur_node.data == address(0)) {
                // visit all the chilins
                for(uint i=0; i<cur_node.children.length; i++) {
                    // only visit valid children
                    if (cur_node.children[i] != 0) {
                        assert(back_i < TREE_VISITATION_QUEUESZ);
                        indexes_to_visit[back_i] = cur_node.children[i];
                        back_i ++;

                    }
                }
            } else {
                ret[ret_i] = cur_node.data;
                ret_i ++;
                if (ret_i > MAX_ADDR_RETURNS) break;
            }
        }

        return ret;
    }

    // when setting, geohash must be precise to 8 digits.
    function setGeoAddr(bytes32 node, bytes8 geohash, address addr) external authorised(node) {
        bytes32(node); // single node georesolver ignores node

        // create root node if not yet created
        if (geomap[node].length == 0) {
            geomap[node].push( Node({
                data: address(0),
                parent: 0,
                children: new uint256[](32)
            }));
        }

        // walk into the geomap data structure
        uint pointer = 0; // not actual pointer but index into geomap
        for(uint i=0; i < geohash.length; i++) {

            uint8 c = chartobase32(geohash[i]);

            if (geomap[node][pointer].children[c] == 0) {
                // nothing found for this geohash.
                // we need to create a path to the leaf
                geomap[node].push( Node({
                    data: address(0),
                    parent: pointer,
                    children: new uint256[](32)
                }));
                geomap[node][pointer].children[c] = geomap[node].length - 1;
            }
            pointer = geomap[node][pointer].children[c];
        }

        Node storage cur_node = geomap[node][pointer]; // storage = get reference
        cur_node.data = addr;

        emit GeoENSRecordChanged(node, geohash, addr);
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == ERC2390 || super.supportsInterface(interfaceID);
    }
}
