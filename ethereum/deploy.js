// deploy code will go here
const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');

const compiledFactory = require('./build/ElectronicHealthRegistry.json');


const provider = new HDWalletProvider(
    'solid daughter desk lounge obvious bread cloud certain punch office leave false',
    'https://rinkeby.infura.io/v3/665482f46c274c1a9842fe88325a5d48'
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log('Attemtipng to deploy from account', accounts[0]);
    
    const result = await new web3.eth.Contract(compiledFactory.abi)
        .deploy({
            data: compiledFactory.evm.bytecode.object
        })
        .send({
            from: accounts[0],
            gas: '3000000'
        });

    
    console.log('Contract deployed to', result.options.address);
    provider.engine.stop();
    

}

deploy();