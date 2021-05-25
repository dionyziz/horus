// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "solidity-bytes-utils/contracts/BytesLib.sol";

library WitnessEncryption {
  function decrypt(bytes memory ciphertext, bytes memory witness) pure internal returns (bytes memory) {
    bytes memory plaintext;

    // ...

    return plaintext;
  }
}

library MerkleTree {
  function verify(bytes memory leaf, uint256 index, bytes32 root, bytes[] memory proof) pure public returns (bool) {
    // ...
  }
}

contract ShortPasswordWallet {
  using BytesLib for bytes;
  uint256 BLOCK_DELAY = 128;
  mapping(bytes32 => bool) commitments;
  bytes ciphertext;
  uint256 expires_at;

  function construct(bytes memory _ciphertext, uint256 _expires_at) public payable {
    ciphertext = _ciphertext;
    expires_at = _expires_at;
  }
  function commit(bytes32 h) public {
    require(block.number < expires_at - BLOCK_DELAY);
    commitments[h] = true;
  }
  function reveal(bytes memory witness, bytes memory password, bytes32 salt, address payable to) public {
    bytes32 h = keccak256(abi.encodePacked(password, salt, to));

    require(commitments[h]);
    require(WitnessEncryption.decrypt(ciphertext, witness).equal(password));

    to.transfer(address(this).balance);
  }
}

contract ShortOTPWallet {
  using BytesLib for bytes;
  uint256 BLOCK_DELAY = 128;
  uint256 AMOUNT_PER_HOUR = 1 ether;
  bytes32 root;
  mapping(uint256 => bool) spent;
  mapping(bytes32 => mapping(uint256 => bool)) commitments;

  function construct(bytes32 _root) public payable {
    root = _root;
  }
  function commit(bytes32 h, uint256 timestamp) public {
    require(timestamp > block.number + BLOCK_DELAY);
    commitments[h][timestamp] = true;
  }
  function reveal(bytes memory OTP, bytes32 salt, address payable to, uint256 amount,
                  bytes memory ciphertext, bytes memory witness,
                  uint256 timestamp, bytes[] memory merkle_proof) public {
    bytes32 h = keccak256(abi.encodePacked(OTP, salt, to, amount));
    require(commitments[h][timestamp]);
    require(amount <= AMOUNT_PER_HOUR);
    require(!spent[timestamp]);
    require(MerkleTree.verify(ciphertext, timestamp, root, merkle_proof));
    require(WitnessEncryption.decrypt(ciphertext, witness).equal(OTP));
    spent[timestamp] = true;
    to.transfer(amount);
  }
}
