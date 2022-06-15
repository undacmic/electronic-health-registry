import web3 from "./web3";

import compiledFactory from './build/ElectronicHealthRegistry.json';

const instance = new web3.eth.Contract
    (
    compiledFactory.abi,
    '0x4fB220c46f586a2B18B9F630cFbDB450Eab8f165'
    );

export default instance;