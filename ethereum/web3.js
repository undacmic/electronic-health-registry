import Web3 from "web3";


let web3;

if(typeof window !== "undefined" && typeof window.ethereum !== "undefined") {

    // Browser, metamask running

    window.ethereum.request({ method: "eth_requestAccounts" });

    web3 = new Web3(window.ethereum);
} else {
    // Server OR NO metamask running

    const provider = new Web3.providers.HttpProvider(
        "https://rinkeby.infura.io/v3/665482f46c274c1a9842fe88325a5d48"
    );

    web3 = new Web3(provider);
}


export default web3;