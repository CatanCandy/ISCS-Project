// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract StakeholderSpending {
    struct OSA {
        string name;
        uint contact;
        uint balance;
        address struct_address;
    }

    struct Organization {
        string name;
        uint contact;
        uint balance;
        address struct_address;
    }

    struct Supplier {
        string name;
        uint contact;
        uint balance;
        address struct_address;
    }


    OSA _admin;

    mapping(address => Organization) public orgs;

    mapping(address => Supplier) public suppliers;

    modifier isOsa{
        require(msg.sender == _admin.struct_address, "You are not an authorized OSA entity.");
        _;
    }

    modifier isOrg{
        require(orgs[msg.sender].struct_address != address(0), "You are not an authorized org entity.");
        _;
    }

    modifier isSupplier{
        require(suppliers[msg.sender].struct_address != address(0), "You are not an authorized supplier entity.");
        _;
    }

    constructor(string memory _name, uint _contact, uint _balance, address _address){
        _admin = OSA({
            name : _name,
            contact : _contact,
            balance : _balance,
            struct_address : _address
        });
    }

    function AllocateOrg(string memory _name, address _address, uint _contact) isOsa external {
        // What if yung aallocate na address may provision na?
        orgs[_address] = Organization({
           name : _name,
           contact :  _contact,
           balance : 0,
           struct_address : _address
        });
    }
    function AllocateSupplier(string memory _name, address _address, uint _contact) isOsa external {
        // What if yung aallocate na address may provision na?
        suppliers[_address] = Supplier({
           name : _name,
           contact :  _contact,
           balance : 0,
           struct_address : _address
        });
    }
    function Check(address Org) external view returns (string memory name) {
        return orgs[Org].name;
    }

    function IncreaseBudget(address _orgAddress, uint _amount) isOsa external {
        orgs[_orgAddress].balance += _amount;
        // what if walang laman yung balance
        // what if non existent address
    }

    function Spend(address _supplierAddress, uint _amount) isOrg external{
        suppliers[_supplierAddress].balance += _amount;
        orgs[msg.sender].balance -= _amount;
        // what if walang laman yung balance
        // what if non existent address
    }

    function Cashout(uint _amount) isSupplier external{
        suppliers[msg.sender].balance -= _amount;
        // what if walang laman yung balance
        // what if non existent address
    }
}