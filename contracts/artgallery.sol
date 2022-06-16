// // SPDX-License-Identifier: MIT OR Apache-2.0
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "./NFT.sol";




// contract NFTCrowdsale is Context, ReentrancyGuard,Ownable {

//     using SafeMath for uint256;
//     using SafeERC20 for IERC20;
    
//     // The token being sold
//     IERC20 private _token;
//     NFT private nft;
//     IERC20 private BUSD;
  
//     // Address where funds are collected
//     address payable private _wallet;
//     address payable public _manager;

//     uint256 private _rate;
//     uint256 private limit = 5260;
//     uint256 public min;
//     uint256 public max;
  
//     //dicounted price
//     uint256 public discounted_Train_common;//0
//     uint256 public discounted_Train_rare;//1
//     uint256 public discounted_Train_epic;//2
//     uint256 public discounted_Train_legendary;//3
//     uint256 public discounted_Station_common;//4
//     uint256 public discounted_Station_mitic;//5
//     uint256 public discounted_Station_Legendary;//6

//     //noraml price
//     uint256 public Train_common;//0
//     uint256 public Train_rare;//1
//     uint256 public Train_epic;//2
//     uint256 public Train_legendary;//3
//     uint256 public Station_common;//4
//     uint256 public Station_mitic;//5
//     uint256 public Station_Legendary;//6
    

//     // Amount of wei raised
//     uint256 private _weiRaised;
//     uint256 public _busdRaised;
//     uint256 private _nftPurchased;
//     bool public success;
//     bool public finalized;
//     bool public pub;
//     bool private discount;


    
//     event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    
//     mapping (address => uint256) private purchase;
//     mapping (address => uint256) private msgValue;
//     uint256 public start;
//     uint256 public limitationtime;
//     uint256 public endTime;
//     uint256 public whitelistCount;
//     mapping(address => bool) private _whitelist;
   
//     constructor( address payable wallet_ ){
//         _wallet = wallet_;
//         start = 0;
//         limitationtime = 0;
//         discounted_Train_common=45 ether;//0 //45
//         discounted_Train_rare=95 ether;//1
//         discounted_Train_epic=190 ether;//2
//         discounted_Train_legendary=470 ether;//3
//         discounted_Station_common=235 ether;//4
//         discounted_Station_mitic=470 ether;//5
//         discounted_Station_Legendary=935 ether;//6


//         Train_common=55 ether;//0 // 55
//         Train_rare=110 ether;//1
//         Train_epic=220 ether;//2
//         Train_legendary=550 ether;//3
//         Station_common=275 ether;//4
//         Station_mitic=550 ether;//5
//         Station_Legendary=1100 ether;

//      BUSD = IERC20(0xca9Eb9DDC1B511d5B67d833D1d36Ee85503DA93E);
    
//         }
    
//     function whitelist(address account)public view returns(bool){
//         return _whitelist[account];
//     }

//     function userPurchased(address account)public view returns(uint256){
//         return purchase[account];
//     }
    
//     function startSale(address[] memory accounts,address _nft,uint256 _startTime) public onlyOwner {
//         //NFT(_nft) req
//         require(address(_nft) != address(0), "NFT: token is the zero address");
//         require(start == 0 ,"Sale already started");
//         nft = NFT(_nft);
//       require(accounts.length!=0 && accounts.length<=1000,"please provide whitelist addresses in limit");
//         if(accounts.length==0){
//         pub = true;
//         }
//         else{
//             pub = false;
//             for (uint256 i = 0; i < accounts.length; i++) {
//                 _addPayee(accounts[i]);
//             }
//         }
       
//         start = block.timestamp + (_startTime * 1 seconds);
//         limitationtime = start + 50 *  1 seconds;
//         endTime = start + 2 weeks * 1 seconds;
//     }

//     function add_whitelistAddresses(address[] memory accounts)  public onlyOwner {
//         require(accounts.length!=0 && accounts.length<=1000,"please provide whitelist addresses in limit");
//          for (uint256 i = 0; i < accounts.length; i++) {
//                 _addPayee(accounts[i]);
//             }
//     }
 
//     fallback () external payable { 
//     }

//     receive () external payable {
//     }


//     /**
//      * @return the address where funds are collected.
//      */
//     function wallet() public view returns (address payable) {
//         return _wallet;
//     }

//     /**
//      * @return the number of token units a buyer gets per wei.
//      */
//     function rate() public view returns (uint256) {
//         return _rate;
//     }

//     /**
//      * @return the amount of wei raised.
//      */
//     function weiRaised() public view returns (uint256) {
//         return _weiRaised;
//     }
    
//     function getTimeStatus() public view returns(bool){
//         if(start<=0){
//             return false;
//         }else if(block.timestamp<=start){
//             return false;
//         }else if(block.timestamp>start){
//             return true;
//         }
//     }

    
//      function getTimeStatusCount() public view returns(uint8){
//         if(start==0){
//             return 0;
//         }else if(start>0 && start <block.timestamp){
//             return 1;
//         }else if(block.timestamp>start && limitationtime < block.timestamp ){
//             return 2;
//         }else if(block.timestamp>limitationtime && endTime<block.timestamp ){
//             return 3;
//         }else if(block.timestamp>endTime){
//             return 4;
//         }
//      }

//     function getPrice(uint8 no) public view returns(uint256){
//         uint256 price;
//         if(block.timestamp>limitationtime && start !=0){
//             price = normal_price(no);
//         }else{
//             price = discount_price(no);
//         }
//         return price;

//     }
//     function TimeCheck()public view returns(bool){
//         if(limitationtime>block.timestamp){
//             return false;
//         }
//         else{
//             return true;
//         }
//     }

//     function blocktimestamp()public view returns(uint256){
//         return block.timestamp * 1 seconds;
//     }
  


//     function startTime()public view returns(uint256){
//         uint256 time=0;
//         if(start !=0 && start>block.timestamp){
//             time = start-block.timestamp;
//         }
//         return time; 
//     }
//     function discountTime()public view returns(uint256){
//         uint256 time=0;
//         if(start !=0 && limitationtime>block.timestamp){
//             time = limitationtime-block.timestamp;
//         }
//         return time; 
//     }

//     function limitationTime()public view returns(uint256){
//         uint256 time=0;
//         if(start !=0 && start>block.timestamp){
//             time = start-block.timestamp;
//         }
//         return time; 
//     }

//     function blocktime()public view returns(uint256){
//         return block.timestamp * 1 seconds;
//     }


//     function buyNFTV1(uint8 no,string memory uri) public nonReentrant payable {
       
//         require(start<block.timestamp && start !=0,"Sale not started");
//         require(endTime>block.timestamp,"Sale has ended");
//         uint256 price;
//         if(block.timestamp<limitationtime){
//             require (_whitelist[_msgSender()] == true,"you are not whitelisted");
//             price = discount_price(no);    
//         }else{
//             price = normal_price(no);        
//         }
//         require (purchase[_msgSender()] < 5,"cant buy more nft");
//         require(_nftPurchased < limit,"All nft Sold");
//         require (!finalized,"Sale Ended");
//         require (BUSD.allowance(_msgSender(), address(this))>=price,"please Approve exact amount for one NFT");

//         nft.createToken(uri,_msgSender(),no);

        
//         _nftPurchased ++;

//         purchase[_msgSender()]++;

//         // update state
//         _busdRaised = _busdRaised.add(price);

//         BUSDTransferFrom(
//         _msgSender(),
//         wallet(),
//         price
//     );   
//     }

//     function Finalize() public  returns(bool) {
//         require(!finalized,"already finalized");
//         require( limit == _nftPurchased, "the crowdSale is in progress");
//             //nft.transferOwnership(_wallet);
//         finalized = true;
//         return finalized;
//     }

//     function BUSDTransferFrom(
//         address from,
//         address to,
//         uint256 value
//     ) private returns(bool){
//        SafeERC20.safeTransferFrom(BUSD, from,to, value);
//      return true;
//     }

//     function _addPayee(address account) private {
//         require(account != address(0), "PaymentSplitter: account is the zero address");
//         _whitelist[account]=true;
//         whitelistCount++;
//     }
    


//     function normal_price(uint8 no) private view returns(uint256){
//         if(no==0){
//                 return Train_common;
//             }else if(no==1){
//                 return Train_rare;
//             }else if(no==2){
//                 return Train_epic;
//             }else if(no==3){
//                 return Train_legendary;
//             }else if(no==4){
//                 return Station_common;
//             }else if(no==5){
//                 return Station_mitic;
//             }else if(no==6){
//                 return Station_Legendary;
//             }else{
//                 require(false,"price :: Type not found");
//             }
//     }

//     function discount_price(uint8 no) private view returns(uint256){
//         if(no==0){
//                 return discounted_Train_common;
//             }else if(no==1){
//                 return discounted_Train_rare;
//             }else if(no==2){
//                 return discounted_Train_epic;
//             }else if(no==3){
//                 return discounted_Train_legendary;
//             }else if(no==4){
//                 return discounted_Station_common;
//             }else if(no==5){
//                 return discounted_Station_mitic;
//             }else if(no==6){
//                 return discounted_Station_Legendary;
//             }else{
//                 require(false,"price :: Type not found");
//             }
//     }
      
// }