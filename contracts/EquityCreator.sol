// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract EquityCreator {
    struct Company {
       string name;
       bool isPublic;
       uint shareAmount;
       uint sharePrice;
       uint companyId;
    }
    Company[] public companies;
    mapping (uint => address) companyToOwner;


    function createCompany(string memory _name, bool _isPublic, uint _shareAmount, uint _sharePrice) public {
        
        uint companyId = _generateRandomId(_name);
        companies.push(Company(_name, _isPublic, _shareAmount, _sharePrice, companyId));
        companyToOwner[companyId] = msg.sender;
    }

    function _generateRandomId(string memory _companyName) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_companyName, msg.sender, block.timestamp)));
    }

}