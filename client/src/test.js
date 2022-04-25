const DoubleAuction = require('./contracts/DoubleAuction.json');
const Web3 = require('web3');

main = async () => {
    const url = 'ws://127.0.0.1:7545';
    const web3 = new Web3(url);

    const accounts = await web3.eth.getAccounts();
    // console.log(accounts);

    const networkId = await web3.eth.net.getId();
    const deployedNetwork = DoubleAuction.networks[networkId];
    const instance = new web3.eth.Contract(
        DoubleAuction.abi, deployedNetwork && deployedNetwork.address
    );

    instance.events.change({}).on('data', event => {
        console.log(event.returnValues);
    })

    await setDefaultValue(instance, accounts);
    await setAsksAndBids(instance, accounts);
    await getQmv(instance, accounts);

}
setDefaultValue = async (contract, accounts) => {
    console.log('\n========== Set Default Value ==========\n')
    await contract.methods.joinAuction("seller", 149, 619).send({ from: accounts[0], gas: 3000000 });
    await contract.methods.joinAuction("seller", 50, 597).send({ from: accounts[1], gas: 3000000 });
    await contract.methods.joinAuction("seller", 194, 502).send({ from: accounts[2], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 97, 729).send({ from: accounts[3], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 96, 728).send({ from: accounts[4], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 46, 522).send({ from: accounts[5], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 37, 578).send({ from: accounts[6], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 21, 670).send({ from: accounts[7], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 70, 455).send({ from: accounts[8], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 45, 449).send({ from: accounts[9], gas: 3000000 });

};

setAsksAndBids = async (contract, accounts) => {
    console.log('\n========== Set Asks & Bids ==========\n')
    await contract.methods.setAsksAndBidsList().send({ from: accounts[0], gas: 3000000 });
    const asks = await contract.methods.getAsksList().call();
    const bids = await contract.methods.getBidsList().call();

    console.log(asks);
    console.log(bids);
}

getQmv = async (contract, accounts) => {
    console.log('\n========== Get Qmv ==========\n')
    await contract.methods.getQFunction().send({ from: accounts[0], gas: 3000000 });
    const qmv = await contract.methods.getQmv().call();

    console.log("Qmv: " + qmv)

}

main();