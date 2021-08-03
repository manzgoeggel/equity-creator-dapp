const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');

const EquityContract = artifacts.require('EquityContract');

require('chai')
    .use(require('chai-as-promised'))
    .should()


contract('EquityContract', ([alice, bob]) => {
    let equityContract;
    before(async () => {
        equityContractInstance = await EquityContract.new();
    })

    describe('equity contract test', async () => {
        it('creates a company', async () => {
            const newCompany = await equityContractInstance.createCompany('Tesla Inc.', false, 1000000, 3);

             truffleAssert.eventEmitted(result, 'CompanyRegistered', (event) => {
                return event.owner === equityContractInstance.companyToOwner(event.companyId);
            });

        })

    })

    // describe('Dapp Token deployment', async () => {
    //     it('has a name', async () => {
    //       const name = await dappToken.name()
    //       assert.equal(name, 'DApp Token')
    //     })
    //   })
      
})    