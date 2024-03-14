// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTMarketplace {
    using SafeMath for uint256;

    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) private listings;
    address private nftContract;
    address private paymentToken;
    uint256 private constant purchaseFee = 1000000000000000; // 0.001 BNB in wei

    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);

    constructor(address _nftContract, address _paymentToken) {
        nftContract = _nftContract;
        paymentToken = _paymentToken;
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(msg.sender == IERC721(nftContract).ownerOf(tokenId), "Only the owner can list the NFT");

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);

        if (price > 0) {
            IERC20(paymentToken).transferFrom(msg.sender, address(this), price);
        }

        listings[tokenId] = Listing(tokenId, msg.sender, price, true);
        emit NFTListed(tokenId, msg.sender, price);
    }

    function buyNFT(uint256 tokenId) external payable {
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT is not listed for sale");
        require(msg.value >= listing.price, "Insufficient funds to purchase the NFT");

        address seller = listing.seller;
        uint256 price = listing.price;
        listing.active = false;

        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenId);

        uint256 feeAmount = calculateFee(price);
        uint256 paymentAmount = price.sub(feeAmount);

        if (paymentAmount > 0) {
            payable(seller).transfer(paymentAmount);
        }

        if (feeAmount > 0) {
            IERC20(paymentToken).transferFrom(msg.sender, address(this), feeAmount);
        }

        emit NFTSold(tokenId, seller, msg.sender, price);
    }

    function cancelListing(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT is not listed for sale");
        require(msg.sender == listing.seller, "Only the seller can cancel the listing");

        listing.active = false;

        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTSold(tokenId, listing.seller, address(0), 0);
    }

    function getNFTListing(uint256 tokenId) external view returns (uint256, address, uint256, bool) {
        Listing storage listing = listings[tokenId];
        return (listing.tokenId, listing.seller, listing.price, listing.active);
    }

    function calculateFee(uint256 price) private view returns (uint256) {
        return price.mul(purchaseFee).div(1e18);
    }
}