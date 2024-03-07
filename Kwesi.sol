// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KwesiMint is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    using SafeMath for uint256;
    uint256 private _nextTokenId;
    uint256 maxSupply = 100;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) public allowList;

    constructor(address initialOwner)
        ERC721("KwesiMint", "KWM")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // modify the mint windows
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    ) external onlyOwner {
        // log the current state before modification
        emit MintWindowsStatus(publicMintOpen, allowListMintOpen);

        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;

        // log the updated state after modification
        emit MintWindowsStatus(publicMintOpen, allowListMintOpen);
    }

    // add publicMint and allowListMintOpen Variables 
    function allowListMint() public payable {
        require(allowListMintOpen, "Allowlist Mint Closed");
        require(allowList[msg.sender], "You are not on the allow list");
        require(msg.value == 0.01 ether, "Not enough funds");
        optimizeMint();
    }

    // add payment
    // add limiting of supply
    function publicMint() public payable  {
        require(publicMintOpen, "Public Mint Closed");
        require(msg.value == 0.01 ether, "Not enough funds");
        optimizeMint();
    }

    // optimized for duplicate variables 
    function optimizeMint() internal {
        require(totalSupply() < maxSupply, "Sold Out!");

        // increment _nextTokenId using SafeMath
        uint256 tokenId = _nextTokenId;
        _nextTokenId = _nextTokenId.add(1);

        _safeMint(msg.sender, tokenId);
    }

    // withdraw function 
    function withdraw(address _addr) external onlyOwner {
        // get balance of contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    // populate the allow list 
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }
/*
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal 
        whenNotPaused
        override(ERC721, ERC721Enumerable) 
    
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
*/
    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // event to log the status of mint windows
    event MintWindowsStatus(bool publicMintOpen, bool allowListMintOpen);
}