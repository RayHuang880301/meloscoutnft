// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";

contract MeloScoutNFT is ERC721A, Ownable, ReentrancyGuard {
    using MerkleProof for bytes32[];

    uint256 public price = 0.15 ether;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;
    uint256 public maxPublicMintAmountPerTx = 5;
    bytes32 public root;
    address payable public safe =
        payable(0x6e24f0fF0337edf4af9c67bFf22C402302fc94D3);
    uint256 public constant MAX_SUPPLY = 888;
    string public baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    constructor(
        string memory _newBaseURI,
        uint256 _preSaleStartTime,
        uint256 _preSaleEndTime,
        uint256 _publicSaleStartTime,
        uint256 _publicSaleEndTime
    ) ERC721A("MeloScoutNFT", "MSNFT") {
        baseTokenURI = _newBaseURI;
        preSaleStartTime = _preSaleStartTime;
        preSaleEndTime = _preSaleEndTime;
        publicSaleStartTime = _publicSaleStartTime;
        publicSaleEndTime = _publicSaleEndTime;
    }

    modifier checkMaxSupply(uint256 _amount) {
        require(totalSupply() + _amount <= MAX_SUPPLY, "exceeds total supply");
        _;
    }

    modifier validateProof(bytes32[] calldata _proof) {
        require(
            ERC721A._numberMinted(msg.sender) < 1,
            "wallet already claimed"
        );

        require(
            MerkleProof.verify(
                _proof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "wallet not allowed"
        );

        _;
    }

    function devMint(address _to, uint256 _amount)
        public
        onlyOwner
        checkMaxSupply(_amount)
    {
        _safeMint(_to, _amount);
    }

    function setRoot(bytes32 _newRoot) public onlyOwner {
        root = _newRoot;
    }

    function setSafe(address payable _newSafe) public onlyOwner {
        safe = _newSafe;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    function setPreSaleTime(uint256 _newStartTime, uint256 _newEndTime)
        public
        onlyOwner
    {
        preSaleStartTime = _newStartTime;
        preSaleEndTime = _newEndTime;
    }

    function setPublicSaleTime(uint256 _newStartTime, uint256 _newEndTime)
        public
        onlyOwner
    {
        publicSaleStartTime = _newStartTime;
        publicSaleEndTime = _newEndTime;
    }

    function setMaxPublicMintAmountPerTx(uint256 _amount) public onlyOwner {
        maxPublicMintAmountPerTx = _amount;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function withdrawToSafe() public onlyOwner {
        require(address(safe) != address(0), "safe address not set");

        safe.transfer(address(this).balance);
    }

    function preSaleMint(bytes32[] calldata _proof)
        public
        payable
        checkMaxSupply(1)
        validateProof(_proof)
        nonReentrant
    {
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp <= preSaleEndTime,
            "presale haven't started yet"
        );
        require(msg.value == price, "incorrect payment");
        _safeMint(msg.sender, 1);
    }

    function publicMint(uint256 _amount)
        public
        payable
        checkMaxSupply(_amount)
        nonReentrant
    {
        require(
            _amount <= maxPublicMintAmountPerTx,
            "exceeds max amount per tx"
        );
        require(
            block.timestamp >= publicSaleStartTime &&
                block.timestamp <= publicSaleEndTime,
            "public sale haven't started yet"
        );
        uint256 cost = price * _amount;
        require(msg.value == cost, "incorrect payment");
        _safeMint(msg.sender, _amount);
    }
}
