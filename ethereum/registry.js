import web3 from "./web3";
import HealthRegistry from './build/HealthRegistry.json';

const getCampaignInstance = (address) => {
    return new web3.eth.Contract(
        HealthRegistry.abi,
        address
    );
};

export default getCampaignInstance;