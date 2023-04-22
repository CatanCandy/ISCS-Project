// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract OSAToken is ERC20, AccessControl {

    // Roles
    bytes32 public constant OSA_ROLE = keccak256("OSA_ROLE");
    bytes32 public constant ORG_ROLE = keccak256("ORG_ROLE");
    bytes32 public constant SUP_ROLE = keccak256("SUP_ROLE");

    // Mapping
    mapping (address => string) private _addressToName;

    constructor() ERC20("OSA Token", "OSA") {
        _mint(msg.sender, 100000);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OSA_ROLE, msg.sender);
        _addressToName[msg.sender] = "OSA 0";
    }

    // Access Modifiers
    modifier isOSA{
        require(hasRole(OSA_ROLE, msg.sender), "You are not an authorized OSA entity.");
        _;
    }
    modifier isORG{
        require(hasRole(ORG_ROLE, msg.sender), "You are not an authorized organization entity.");
        _;
    }
    modifier isSUP{
        require(hasRole(SUP_ROLE, msg.sender), "You are not an authorized supplier entity.");
        _;
    }

    // Role Granting Functions

    function _addOSA(string memory name, address account) external isOSA {
        _addressToName[account] = name;
        grantRole(DEFAULT_ADMIN_ROLE, account);
        grantRole(OSA_ROLE, account);
    }
    function _addOrganization(string memory name, address account) external isOSA {
        _addressToName[account] = name;
        grantRole(ORG_ROLE, account);
    }
    function _addSupplier(string memory name, address account) external isOSA {
        _addressToName[account] = name;
        grantRole(SUP_ROLE, account);
    }

    // Events
    event IncreaseOSABudget(string to, uint256 amount);
    event Spend(string from, string to, uint256 amount);
    event Allocate(string from, string to, uint256 amount);
    event Deduct(string from, string to, uint256 amount);
    event Cashout(string by, uint256 amount);

    // Transaction Functions

    function _increaseOSABudget(uint256 amount) external isOSA {
        _mint(msg.sender, amount);
        emit IncreaseOSABudget(_addressToName[msg.sender], amount);
    }

    function _spend(address supplier, uint256 amount) external isORG { // transfer tokens from ORG to SUP
        _transfer(msg.sender, supplier, amount);
        emit Spend(_addressToName[msg.sender], _addressToName[supplier], amount);
    }

    function _allocate(address organization, uint256 amount) external isOSA { // transfer tokens from OSA to ORG
        _transfer(msg.sender, organization, amount);
        emit Allocate(_addressToName[msg.sender], _addressToName[organization], amount);
    }

    function _deduct(address organization, uint256 amount) external isOSA { // transfer tokens from ORG to OSA
        _transfer(organization, msg.sender, amount);
        emit Deduct(_addressToName[organization], _addressToName[msg.sender], amount);
    }

    function _cashout() external isSUP { // cashout all of SUP tokens
        _burn(msg.sender, balanceOf(msg.sender));
        emit Cashout(_addressToName[msg.sender], balanceOf(msg.sender));
    }

    function _myBalance() external view returns(uint256) { // view current account's token balance
        return balanceOf(msg.sender);
    }

    function _myName() external view returns(string memory) { // view current account's name
        return _addressToName[msg.sender];
    }

    function _viewOtherBalance(address account) external isOSA view returns(uint256) { // view token balance of specific account
        return balanceOf(account);
    }

    function _viewOtherName(address account) external isOSA view returns(string memory) { // view name of specific account
        return _addressToName[account];
    }
}
