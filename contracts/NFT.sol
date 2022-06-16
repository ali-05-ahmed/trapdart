// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract NFT is ERC721 , Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    
    bool public revealed ;
    uint256 public revealtime = 15 minutes;
    address private token;
    uint256 price = 0.1 ether; 
    
    // uint256 public tokenIds; 

    uint256 public maxGiveAway = 7777;

    uint256 public limit = 5 ;
    uint256 public limitationtime = block.timestamp + revealtime * 1 seconds;
    address public marketplace = address(0xB6E34EbeC469CdbE8BfF1270Ce8194Ec38B83B11);
    mapping (address => bool) private marketplaces;
    mapping (address => uint256) public purchase;
    mapping (uint256 => bool) private rev;
    using Strings for uint256;
    mapping (uint256 => string) private _tokenURIs;

        

     address public nftAddress;
    uint256 tokenID;
    
    
    struct NftDetails{
        address[] owner;
        uint256 creationTime;
    }

    mapping(address => bool) private _owner;
    mapping(uint256=>NftDetails) private _NftDetails;

    constructor() ERC721("Trap Dart", "TD")  {
       
        _owner[_msgSender()] = true;

        // _owner[preSale] = true;
        // _owner[pubSale] = true;
    }


    function addOwner(address owner_) public {
        require(_owner[_msgSender()]==true,"cannot Assign owner");
        _owner[owner_]=true;
    }

   

    function baseURI() public view returns(string memory){
        return "https://ipfs.io/ipfs/";
    }

    function createToken(address account) public returns (uint) {
        // require(_tokenIds <= 7777);
        require(_tokenIds.current() < 7777 ,"all NFTs Minted");
        require(IERC20(token).transferFrom(_msgSender(),address(this),price),"please send exact amount");
       
        if(_tokenIds.current()>=limit){
            allreveal();
        }
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(account, newItemId);
        // setTokenURI(newItemId,"https://ipfs.io/ipfs/QmeCq9iq1r8U1xKGZwdYiXTX3YByKsRycMpwoDD9uxboib");
        return newItemId;
    }

     
    
        
    function setTokenURI(uint256 tokenId, string memory tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = tokenURI;
    }

    function tokenURI(uint256 tokenId ) public view  override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory URI;
        if(rev[tokenId] && revealed && block.timestamp >= limitationtime ){
            URI = "https://ipfs.io/ipfs/QmeCq9iq1r8U1xKGZwdYiXTX3YByKsRycMpwoDD9uxboib";      
        }   
        else{
            URI = "https://ipfs.io/ipfs/QmUyZgUGzsf1XzoMy8hVstaqc3rHRFxssr5mNrSBt1DU2M";
        }
        return URI;
    }

    function getNftDetails(uint256 _tokenId)private view returns(NftDetails memory){
        return _NftDetails[_tokenId];
    }

    function totalSupply() private view returns(uint256){
        return _tokenIds.current();
    }

    //  require(id >= limit && block.timestamp >= limitationtime , "All NFT should be Minted");

    function setTokenAddress(address _token) public onlyOwner{
        require(_token != address(0),"0 address");
        token = _token ;
    }

     function allreveal()  private {
       revealed = true;
    }

    function getTime() private view returns(uint256){
        return block.timestamp;
    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if(isContract(_msgSender()) && from != address(0)){     
            rev[tokenId] = true ;
        }
    }

      function AirDrop(string memory tokenURI , address account) public onlyOwner {
        createToken(account);
    }
   

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal override {
        super._setApprovalForAll(
       owner,
      operator,
      approved
    );
    }
    
   function isContract(address _addr) private returns (bool isContract){
  uint32 size;
  assembly {
    size := extcodesize(_addr)
  }
  return (size > 0);
}
    
}