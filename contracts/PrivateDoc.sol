// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {BN254EncryptionOracle as Oracle} from "./medusa/BN254EncryptionOracle.sol";
import {IEncryptionClient, Ciphertext} from "./medusa/EncryptionOracle.sol";
import {G1Point} from "./medusa/Bn128.sol";
import {PullPayment} from "@openzeppelin/contracts/security/PullPayment.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error CallbackNotAuthorized();
error ListingDoesNotExist();
error CallerIsNotNftOwner();

// struct Listing {
//     address seller;
//     uint256 cipherId;
// }

contract PrivateDoc is IEncryptionClient, PullPayment {
    /// @notice The Encryption Oracle Instance
    Oracle public oracle;
    address public nft;

    /// @notice A mapping from cipherId to listing
    mapping(string => uint256) public listings;
    mapping(string => uint256) public requests;
    mapping(uint256 => Ciphertext) public ciphers;

    event ListingDecryption(uint256 indexed requestId, Ciphertext ciphertext);

    event NewListing(
        address indexed seller,
        uint256 indexed cipherId,
        string uri
    );

    event NewSale(
        address indexed seller,
        uint256 requestId,
        uint256 cipherId,
        string uri
    );

    modifier onlyOracle() {
        if (msg.sender != address(oracle)) {
            revert CallbackNotAuthorized();
        }
        _;
    }

    constructor(Oracle _oracle, address _nft) {
        oracle = _oracle;
        nft = _nft;
    }

    /// @notice Create a new listing
    /// @dev Submits a ciphertext to the oracle, stores a listing, and emits an event
    function createListing(
        Ciphertext calldata cipher,
        string calldata uri
    ) external {
        try oracle.submitCiphertext(cipher, bytes("0x"), msg.sender) returns (
            uint256 cipherId
        ) {
            listings[uri] = cipherId;
            emit NewListing(msg.sender, cipherId, uri);
        } catch {
            require(false, "Call to Medusa oracle failed");
        }
    }

    /// @notice Pay for a listing
    /// @dev Buyer pays the price for the listing, which can be withdrawn by the seller later; emits an event
    /// @return requestId The id of the reencryption request associated with the purchase
    function buyListing(
        string memory _uri,
        G1Point calldata buyerPublicKey
    ) external returns (uint256) {
        // Listing memory listing = listings[uri];
        // if (listing.seller == address(0)) {
        //     revert ListingDoesNotExist();
        // }

        // if (ERC721(nft).balanceOf(msg.sender) < 1) {
        //     revert InsufficentFunds();
        // }
        // (bool success, bytes memory check) = nft.call(
        //     abi.encodeWithSignature("balanceOf(address)", msg.sender)
        // );

        // if (!success || check[0] == 0) {
        //     revert CallerIsNotNftOwner();
        // }

        // _asyncTransfer(listing.seller, msg.value);
        uint256 requestId = oracle.requestReencryption(
            listings[_uri],
            buyerPublicKey
        );
        // emit NewSale(msg.sender, requestId, listings[_uri], _uri);
        requests[_uri] = requestId;
        return requestId;
    }

    /// @inheritdoc IEncryptionClient
    function oracleResult(
        uint256 requestId,
        Ciphertext calldata cipher
    ) external onlyOracle {
        emit ListingDecryption(requestId, cipher);
        ciphers[requestId] = cipher;
    }

    /// @notice Convenience function to get the public key of the oracle
    /// @dev This is the public key that sellers should use to encrypt their listing ciphertext
    /// @dev Note: This feels like a nice abstraction, but it's not strictly necessary
    function publicKey() external view returns (G1Point memory) {
        return oracle.distributedKey();
    }
}
