// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";


contract EquityContract is Ownable {
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

 
    
    uint companyRegistractionFee = 0.05 ether;
    Company[] public companies;
    mapping (uint => address) public companyToOwner;
    mapping (uint => Shareholder[]) public companyShareholders;

    event SharesTransfer(address previousOwner, address newOwner, uint companyId, uint shares);
    event CompanyRegistered(address owner, string name, uint companyId);

    function createCompany(string memory _name, bool _isPublic, uint _shares, uint _sharePrice) public payable {

        //send the registration fee to the owner of contract
        assert(msg.value >= companyRegistractionFee);

        address payable _owner = payable(owner());
        _owner.transfer(companyRegistractionFee);

        //create the new company
        uint companyId = _generateRandomId(_name);
        companies.push(Company(_name, _isPublic, _shares, _shares, _sharePrice, companyId));
        companyToOwner[companyId] = msg.sender;

        emit CompanyRegistered(msg.sender, _name, companyId);
    }

    function transferSharesCompanyToShareholder(address _to, uint _shares, uint _companyId, string memory _shareholderName) external onlyOwnerOf(_companyId) {
        Company storage company = companies[_companyId];

        require(company.companyId == _companyId, 'no company found.');
        require(company.shares >= _shares, 'you cannot transfer more shares than you have');

        //new company total
        company.shares = company.shares - _shares;

        Shareholder[] storage shareholders = companyShareholders[_companyId];
        uint shareholderId = _generateShareholderId(_shareholderName, _to);
        
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
        emit SharesTransfer(msg.sender, _to, _companyId, _shares);
    }


    function getMarketCap(uint _companyId) public view returns (uint) {
        Company memory company = companies[_companyId];
        return company.shares * company.sharePrice;
    }

    function setSharePrice(uint _companyId, uint _newSharePrice) external onlyOwnerOf(_companyId) {
        Company storage company = companies[_companyId];
        company.sharePrice = _newSharePrice;

    }

    //helper functions
    function _generateRandomId(string memory _str) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_str, msg.sender, block.timestamp)));
    }
       
    function _generateShareholderId(string memory _name, address _shareholder) private pure returns (uint) {
        return uint(keccak256(abi.encodePacked(_name, _shareholder)));
    }
    modifier onlyOwnerOf(uint _companyId) {
        require(msg.sender == companyToOwner[_companyId]);
        _;
    }


}