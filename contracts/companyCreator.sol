// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";

contract CompanyCreator is Ownable {
    struct Company {
       string name;
       bool isPublic;
       uint shares;
       uint totalShares;
       uint sharePrice;
       uint companyId;
    }

     struct Shareholder {
        string name;
        uint shareAmount;
        uint companyId;
        uint shareholderId;
        
    }

    Company[] public companies;
    mapping (uint => address) companyToOwner;
    mapping (uint => Shareholder[]) companyShareholders;


    event CompanyTransfer(address _previousOwner, address _newOwner, uint companyId);

    function createCompany(string memory _name, bool _isPublic, uint _shares, uint _sharePrice) public {
        
        uint companyId = _generateRandomId(_name);
        companies.push(Company(_name, _isPublic, _shares, _shares, _sharePrice, companyId));
        companyToOwner[companyId] = msg.sender;
    }

    function transferShares(address _to, uint _shares, uint _companyId, string memory _shareholderName) external payable onlyOwnerOf(_companyId) {

        Company memory company = companies[_companyId];
        require(company.shares >= _shares, 'you cannot transfer more shares than you have');

        //new company total
        company.shares = company.shares - _shares;

        Shareholder[] storage shareholders = companyShareholders[_companyId];
        uint shareholderId = _generateShareholderId(_shareholderName);
        
        //check if there's already a shareholder 
        if (shareholders[shareholderId].shareholderId == shareholderId) {
            //update the shareholder's shares
            shareholders[shareholderId].shareAmount = shareholders[shareholderId].shareAmount + _shares;

        } else {
             //create a new shareholder
            shareholders.push(Shareholder(
            _shareholderName,
            _shares,
            _companyId,
            shareholderId
            
        ));
            
        }
    }

    function getMarketCap(uint _companyId) public view returns (uint) {
        Company memory company = companies[_companyId];
        return company.shares * company.sharePrice;
    }

    function _generateRandomId(string memory _str) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_str, msg.sender, block.timestamp)));
    }
     function _generateShareholderId(string memory _name) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_name, msg.sender)));
    }

    modifier onlyOwnerOf(uint _companyId) {
        require(msg.sender == companyToOwner[_companyId]);
        _;
    }


}