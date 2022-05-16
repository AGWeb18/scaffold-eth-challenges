pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    uint256 public constant tokensPerEth = 100;

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        uint256 _amountInEth = msg.value;
        require(_amountInEth > 0, "You need to buy some...");

        uint256 _amountOfTokens = tokensPerEth * _amountInEth;

        uint256 vendorTokenBalance = yourToken.balanceOf(address(this));

        require(
            vendorTokenBalance >= _amountOfTokens,
            "Vendor doesn't have enough Tokens"
        );

        bool buySuccess = yourToken.transfer(msg.sender, _amountOfTokens);
        require(buySuccess, "Purchase was not successful");
        emit BuyTokens(msg.sender, _amountInEth, _amountOfTokens);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        uint256 vendorBalance = yourToken.balanceOf(address(this));
        bool _withdrawSuccess = yourToken.transfer(msg.sender, vendorBalance);
        require(_withdrawSuccess, "withdraw wasn't successful");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public payable {
        require(_amount > 0, "need to sell SOME...");
        uint256 _sellAmountInEth = _amount / tokensPerEth;
        address _buyingTokens = address(this);
        address _sellingTokens = msg.sender;
        bool tokenApproval = yourToken.approve(_buyingTokens, msg.value);
        require(tokenApproval, "Token was not approved");

        uint256 tokenAllowance = yourToken.allowance(
            _sellingTokens,
            _buyingTokens
        );
        require(_amount <= tokenAllowance, "allowance is too low");

        bool sellTransfer = yourToken.transferFrom(
            _sellingTokens,
            _buyingTokens,
            _amount
        );
        payable(_sellingTokens).transfer(_sellAmountInEth);
        require(sellTransfer, "transferFrom failed");
        emit SellTokens(_sellingTokens, _sellAmountInEth, _amount);
    }
}
