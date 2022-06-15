const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const  buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const eletronicRecordPath = path.resolve(__dirname, 'contracts', 'ElectronicHealthRegistry.sol');
const source = fs.readFileSync(eletronicRecordPath, 'utf8');

const input = {
    language: 'Solidity',
    sources: {
        'ElectronicHealthRegistry.sol': {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*'],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input))).contracts;

fs.ensureDirSync(buildPath);
for( let contract in output['ElectronicHealthRegistry.sol']) {
    fs.outputJSONSync(
        path.resolve(buildPath,contract+'.json'),
        output['ElectronicHealthRegistry.sol'][contract],
    );
}
