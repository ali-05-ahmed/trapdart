// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TrapDart is ERC20Burnable  , Ownable {
    
    uint256 initialSuppply = 88888888 *10**18;

    constructor(address _vesting , address _crowdsale) ERC20("TRAP", "TRAP") {
 
        _mint(_vesting, (initialSuppply/100)*20);
        _mint(_crowdsale, (initialSuppply/100)*40);
        _mint(_msgSender(), (initialSuppply/100)*40);
        
    }

}