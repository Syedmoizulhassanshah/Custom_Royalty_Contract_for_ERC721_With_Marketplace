// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract MarketPlace is ERC721Enumerable{
    
    address public artist;
    uint256 public royalityFee;
    uint256 public cost = 1 ether;
    uint256 public maxSupply = 20;

    address MarketPlaceOwner;
    mapping(uint256 => bool) internal hasSoldToken; // map the "tokenID" to its sold status "true/false". 
    

    constructor( string memory _name,string memory _symbol,uint256 _royalityFee,address _artist) ERC721(_name,_symbol)
    {
        royalityFee = _royalityFee;
        artist = _artist;
        MarketPlaceOwner = msg.sender;
    }
    
     function mint() public {
        uint256 supply = totalSupply();
        require(supply <= maxSupply);
           _safeMint(msg.sender,supply + 1);
        
     }
     
     function BuyTokens(uint256 _tokenId) payable external {
          require( msg.value >= cost,"Kindly pay Ether to buy the NFT");
 
 /* works only if the token is being sold for the first time.*/         
         if(hasSoldToken[_tokenId]== false && msg.value >= cost)
         {
               hasSoldToken[_tokenId]=true;
               address _OwnerOfToken=ownerOf(_tokenId);
               uint256 _primaryFee = (msg.value* 10)/100; //10 percent commission of market place.
               uint256 _PriceOFtokenAfterMarketPalaceCommission= msg.value-_primaryFee; // 90 percent remaining value send to the owner of the NFT. 
               _safeTransfer(_OwnerOfToken,msg.sender,_tokenId," ");
                 
               payable (_OwnerOfToken).transfer(_PriceOFtokenAfterMarketPalaceCommission);
               primaryFee( _primaryFee); // calling the function to transfer the primary fee  to the market place. 
           
         }// end of if
         

// works only if the token is sold already and being resold. 
         else if (hasSoldToken[_tokenId]==true && msg.value>= 5 ether)
           {
               
               address _OwnerOfToken=ownerOf(_tokenId);
                uint256 _royalty =(msg.value*royalityFee)/100;
                uint256 _SecondaryFee = (msg.value* 10)/100; //15 percent commission of market place when the token is resold.
                uint256 _PriceOFtokenAfterMarketPalaceCommission= (msg.value- _royalty -_SecondaryFee); //  80 percent remaining value send to the owner of the NFT. 
               _safeTransfer(_OwnerOfToken,msg.sender,_tokenId," ");
               payable(artist).transfer(_royalty);  // transfers royalty  to the artist.
               payable (_OwnerOfToken).transfer(_PriceOFtokenAfterMarketPalaceCommission);
               secondaryFee(_SecondaryFee); // calling the function to transf er the secondary fee to the market place.
           } //end of  else-if
         
     }
     
     
     // transfers primaryFee to the MarketPlaceOwner.
     
     function  primaryFee( uint256 _pcommission) public 
     {
         
         payable (MarketPlaceOwner).transfer(_pcommission);
         
     }
     
     // transfers secondaryFee to the MarketPlaceOwner.
     
     function secondaryFee( uint256 _Scommission) public
     {
     
         payable (MarketPlaceOwner).transfer(_Scommission);
     }
     
     
     
    
}// end of contract


