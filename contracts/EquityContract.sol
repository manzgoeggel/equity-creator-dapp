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

 
    
    uint public companyRegistractionFee = 0.05 ether;
    mapping(address => Company) public ownerToCompany;
    mapping (uint => address) public companyIdToOwner;
    mapping (uint => Shareholder[]) public companyShareholders;
    mapping (uint => uint) public companyShareholdersCount;

    event SharesTransfer(address previousOwner, address newOwner, uint companyId, uint shares, uint shareholderIndex);
    event CompanyRegistered(address owner, string name, uint companyId);

    function createCompany(string memory _name, bool _isPublic, uint _shares, uint _sharePrice) public payable {

        //send the registration fee to the owner of contract
        assert(msg.value >= companyRegistractionFee);

        address payable _owner = payable(owner());
        _owner.transfer(companyRegistractionFee);

        //create the new company
        uint companyId = _generateRandomId(_name);
        ownerToCompany[msg.sender] = Company(_name, _isPublic, _shares, _shares, _sharePrice, companyId);
        companyIdToOwner[companyId] = msg.sender;
        companyShareholdersCount[companyId] = 0;

        emit CompanyRegistered(msg.sender, _name, companyId);
    }

    function transferSharesCompanyToShareholder(address _to, uint _shares, uint _companyId, string memory _shareholderName) public onlyOwnerOf(_companyId) {
       
       
        require(ownerToCompany[msg.sender].companyId == _companyId, 'no company found.');
        require(ownerToCompany[msg.sender].shares >= _shares, 'you cannot transfer more shares than you have');

        //new company total
        ownerToCompany[msg.sender].shares =  ownerToCompany[msg.sender].shares - _shares;

        Shareholder[] memory shareholders = companyShareholders[_companyId];
        uint shareholderId = _generateShareholderId(_shareholderName, _to);
        

        // //check if there's already a shareholder 
        uint shareholderIndex = getShareholderIndex(shareholderId, _companyId);
        if (companyShareholdersCount[_companyId] != 0 && shareholderIndex != 9999) {
            //update the shareholder's shares
            shareholders[shareholderId].shareAmount = shareholders[shareholderId].shareAmount + _shares;

        } else {
             //create a new shareholder
                companyShareholders[_companyId].push(Shareholder(
                _shareholderName,
                _shares,
                _companyId,
                shareholderId
                
            ));
            companyShareholdersCount[_companyId]++;
            shareholderIndex = companyShareholdersCount[_companyId] - 1;
            
        }
        emit SharesTransfer(msg.sender, _to, _companyId, _shares, shareholderIndex);
    }

    function getShareholderIndex(uint _shareholderId, uint _companyId) public view returns (uint) {
        for (uint i = 0; i < companyShareholdersCount[_companyId]; i++) {
            if (companyShareholders[_companyId][i].shareholderId == _shareholderId) {
                return i;
            }
        }
        return 9999;
    }
    function getMarketCap(uint _companyId) public view returns (uint) {
        address companyAddress = companyIdToOwner[_companyId]; 
        return ownerToCompany[companyAddress].shares * ownerToCompany[companyAddress].sharePrice;
    }

    function setSharePrice(uint _companyId, uint _newSharePrice) public onlyOwnerOf(_companyId) {
        ownerToCompany[msg.sender].sharePrice = _newSharePrice;

    }

    //helper functions
    function _generateRandomId(string memory _str) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_str, msg.sender, block.timestamp)));
    }
       
    function _generateShareholderId(string memory _name, address _shareholder) private pure returns (uint) {
        return uint(keccak256(abi.encodePacked(_name, _shareholder)));
    }
    modifier onlyOwnerOf(uint _companyId) {
        require(msg.sender == companyIdToOwner[_companyId]);
        _;
    }


}