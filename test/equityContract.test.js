const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');

const EquityContract = artifacts.require('EquityContract');

require('chai')
    .use(require('chai-as-promised'))
    .should()


contract('EquityContract', ([alice, bob]) => {
    let equityContractInstance;
    before(async () => {
        equityContractInstance = await EquityContract.new();
    })

    describe('equity contract', async () => {
        it('creates a company', async () => {
            const result = await equityContractInstance.createCompany('Tesla Inc.', false, 100000, 3, { from: alice, value: web3.utils.toWei("0.05", "ether")});
            //extracts the emitted values from the 'CompanyRegistered' event
            const { owner, companyId } = await result.logs[0].args;
            const _owner = await equityContractInstance.companyIdToOwner(companyId);

            //checks if the company owner is stored correctly.
            assert.equal(owner, _owner);

       
          
        })

        it('creates a shareholder & transfers shares from company to shareholder', async () => {
            const company = await equityContractInstance.ownerToCompany(alice);
            const {companyId} = await company;
            const result = await equityContractInstance.transferSharesCompanyToShareholder(bob, 5000, companyId, 'lukas steiner', {from: alice});

            const shareholderIndex = await result.logs[0].args.shareholderIndex;
            const shareholder = await equityContractInstance.companyShareholders(companyId, shareholderIndex);

            //check if the shareholder received his shares
            assert.equal(shareholder.shareAmount, 5000);
           
        })
    
     
    })

      
})    