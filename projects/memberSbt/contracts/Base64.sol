// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Base64
 * @notice Provides Base64 encoding functionality for on-chain data
 * @dev Pure library for encoding bytes to Base64 string
 */
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Encodes bytes to Base64 string
     * @param data The bytes to encode
     * @return The Base64 encoded string
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // Loads the table into memory
        string memory table = string(TABLE);

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory tableBytes = bytes(table);

        uint256 idx = 0;
        uint256 i = 0;
        for (i = 0; i + 3 <= len; i += 3) {
            uint256 triplet = (uint256(uint8(data[i])) << 16) +
                (uint256(uint8(data[i + 1])) << 8) +
                uint256(uint8(data[i + 2]));

            result[idx++] = tableBytes[(triplet >> 18) & 0x3F];
            result[idx++] = tableBytes[(triplet >> 12) & 0x3F];
            result[idx++] = tableBytes[(triplet >> 6) & 0x3F];
            result[idx++] = tableBytes[triplet & 0x3F];
        }

        // Handle remaining bytes
        if (i < len) {
            uint256 triplet = 0;
            uint256 paddingLen = 0;

            if (i + 1 == len) {
                // 1 byte left
                triplet = uint256(uint8(data[i])) << 16;
                paddingLen = 2;
            } else {
                // 2 bytes left
                triplet = (uint256(uint8(data[i])) << 16) + (uint256(uint8(data[i + 1])) << 8);
                paddingLen = 1;
            }

            result[idx++] = tableBytes[(triplet >> 18) & 0x3F];
            result[idx++] = tableBytes[(triplet >> 12) & 0x3F];

            if (paddingLen == 2) {
                result[idx++] = 0x3d; // '='
                result[idx++] = 0x3d; // '='
            } else {
                result[idx++] = tableBytes[(triplet >> 6) & 0x3F];
                result[idx++] = 0x3d; // '='
            }
        }

        // Resize the result to the actual length
        bytes memory finalResult = new bytes(encodedLen);
        for (uint256 j = 0; j < encodedLen; j++) {
            finalResult[j] = result[j];
        }

        return string(finalResult);
    }
}