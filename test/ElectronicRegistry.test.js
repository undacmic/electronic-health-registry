const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledFactory = require('../ethereum/build/ElectronicHealthRegistry.json');
const compiledRegistry = require('../ethereum/build/HealthRegistry.json');

let accounts;
let factory;
let registryAddress;
let registry;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    factory = await new web3.eth.Contract(compiledFactory.abi)
                .deploy({
                    data: compiledFactory.evm.bytecode.object
                })
                .send({
                    from: accounts[0],
                    gas: '3000000'
                });

    await factory.methods.createUser('Dragos',
                                    'Ioana',
                                    '5000120160037',
                                    'Craiova',
                                    'dragosioana20@gmail.com',
                                    '0724994318',
                                    '20.01.2000',
                                    '184',
                                    '76',
                                    '2',
                                    accounts[0])
                                    .send({
                                        from: accounts[0],
                                        gas: '3000000'
                                    });
        
    registryAddress = await factory.methods.deployedRegistries(accounts[0]).call();
    registry = await new web3.eth.Contract(compiledRegistry.abi, registryAddress);


});


describe('Electronic Health Reigstry', () => {

    it('can deploy a factory and a registry', () => {
        assert.ok(factory.options.address);
        assert.ok(registry.options.address);
    })

});