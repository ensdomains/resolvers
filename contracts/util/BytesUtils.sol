pragma solidity ^0.5.0;


library BytesUtils {
    /*
     * @dev Returns the keccak-256 hash of a byte range.
     * @param self The byte string to hash.
     * @param offset The position to start hashing at.
     * @param len The number of bytes to hash.
     * @return The hash of the byte range.
     */
    function keccak(bytes memory self, uint offset, uint len) internal pure returns (bytes32 ret) {
        require(offset + len <= self.length);
        assembly {
            ret := keccak256(add(add(self, 32), offset), len)
        }
    }

    /*
     * @dev Compares ranges of two different bytes objects and returns true iff
     *      they are equal.
     * @param self The first byte range to compare.
     * @param offset The offset into the first byte range.
     * @param other The second byte range to compare.
     * @param otherOffset The offset into the second byte range.
     * @param len The number of bytes to compare
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(bytes memory self, uint offset, bytes memory other, uint otherOffset, uint len) internal pure returns (bool) {
        return keccak(self, offset, len) == keccak(other, otherOffset, len);
    }

    /*
     * @dev Compares a range of 'self' to all of 'other' and returns True iff
     *      they are equal.
     * @param self The first byte range to compare.
     * @param offset The offset into the first byte range.
     * @param other The second byte range to compare.
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(bytes memory self, uint offset, bytes memory other) internal pure returns (bool) {
        return self.length >= offset + other.length && equals(self, offset, other, 0, other.length);
    }

    /*
     * @dev Returns true if the two byte ranges are equal.
     * @param self The first byte range to compare.
     * @param other The second byte range to compare.
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(bytes memory self, bytes memory other) internal pure returns(bool) {
        return self.length == other.length && equals(self, 0, other, 0, self.length);
    }

    /*
     * @dev Returns the 8-bit number at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the slice
     * @return The specified 8 bits of the string, interpreted as an integer.
     */
    function readUint8(bytes memory self, uint idx) internal pure returns (uint8 ret) {
        require(idx + 1 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 1), idx)), 0xFF)
        }
    }

    /*
     * @dev Returns the 16-bit number at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the slice
     * @return The specified 16 bits of the string, interpreted as an integer.
     */
    function readUint16(bytes memory self, uint idx) internal pure returns (uint16 ret) {
        require(idx + 2 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 2), idx)), 0xFFFF)
        }
    }

    /*
     * @dev Returns the 32-bit number at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the slice
     * @return The specified 32 bits of the string, interpreted as an integer.
     */
    function readUint32(bytes memory self, uint idx) internal pure returns (uint32 ret) {
        require(idx + 4 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 4), idx)), 0xFFFFFFFF)
        }
    }

    /*
     * @dev Returns the 32 byte value at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the slice
     * @return The specified 32 bytes of the string.
     */
    function readBytes32(bytes memory self, uint idx) internal pure returns (bytes32 ret) {
        require(idx + 32 <= self.length);
        assembly {
            ret := mload(add(add(self, 32), idx))
        }
    }

    /*
     * @dev Returns the 32 byte value at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the slice
     * @return The specified 32 bytes of the string.
     */
    function readBytes20(bytes memory self, uint idx) internal pure returns (bytes20 ret) {
        require(idx + 20 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 32), idx)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000)
        }
    }

    function memcpy(uint dest, uint src, uint len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Copies a substring into a new byte string.
     * @param self The byte string to copy from.
     * @param offset The offset to start copying at.
     * @param len The number of bytes to copy.
     */
    function substring(bytes memory self, uint offset, uint len) internal pure returns(bytes memory) {
        require(offset + len <= self.length);

        bytes memory ret = new bytes(len);
        uint dest;
        uint src;

        assembly {
          dest := add(ret, 32)
          src := add(add(self, 32), offset)
        }
        memcpy(dest, src, len);

        return ret;
    }
}
