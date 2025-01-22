// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduCredentialsStore {
    // Store the hash of the strings and their corresponding block number
    mapping (bytes32 => uint) private proofs;
    
    // Define an event
    event Result(
        address indexed from,
        string document,
        uint blockNumber
    );
    
    // Store the owner of the contract
    address public owner;
    
    // Constructor to initialize the owner
    constructor() {
        owner = msg.sender;
    }
    
    // Store a proof of existence in the contract state
    function storeProof(bytes32 proof) private {
        proofs[proof] = block.number;
    }
    
    // Calculate and store the proof for a document
    function storeEduCredentials(string calldata document) external {
        require(msg.sender == owner, "Only the owner of the contract can store the credentials");
        bytes32 proof = proofFor(document);
        require(proofs[proof] == 0, "Credential already stored");
        storeProof(proof);
    }
    
    // Helper function to get a document's sha256 hash
    function proofFor(string calldata document) private pure returns (bytes32) {
        return sha256(bytes(document));
    }
    
    // Check if a document has been saved previously
    function checkEduCredentials(string calldata document) external payable {
        bytes32 proof = proofFor(document);
        uint blockNumber = proofs[proof];

        require(msg.value >= 1000 wei, "Insufficient fee: Minimum 1000 wei required");

        // Emit event with block number (0 if not found)
        emit Result(msg.sender, document, blockNumber);
    }
    
    // Withdraw contract balance (only owner)
    function cashOut() external {
        require(msg.sender == owner, "Only the owner can cash out!");
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to handle unexpected transactions
    receive() external payable {}
}
