import React, { Component } from "react";
import DoubleAuctionContract from "./contracts/DoubleAuction.json";
// import getWeb3 from "./getWeb3";
import Web3 from "web3";
import "./App.css";

class App extends Component {
  state = { sellerList: [], buyerList: [], inputRole: "seller", inputQuantity: 149, inputPrice: 619, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      // const web3 = await getWeb3();
      const url = 'http://127.0.0.1:7545';
      const web3 = new Web3(url);

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = DoubleAuctionContract.networks[networkId];
      const instance = new web3.eth.Contract(
        DoubleAuctionContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance });
      this.getExisingList()
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  joinAuction = async () => {
    const { contract, inputRole, inputQuantity, inputPrice } = this.state;

    if (window.ethereum) {

      // res[0] for fetching a first wallet
      await window.ethereum
        .request({ method: "wallet_requestPermissions", params: [{ eth_accounts: {} }] })
        .then(() => window.ethereum.request({ method: "eth_requestAccounts" }))
        .then((res) => contract.methods.joinAuction(inputRole, inputQuantity, inputPrice).send({ from: res[0], gas: 3000000 }));
      // .then((res) => console.log(res[0]))

    } else {
      alert("請下載 metamask !!");
    }

    this.getExisingList();
  }

  setDefaultValue = async () => {
    const { accounts, contract } = this.state;

    await contract.methods.joinAuction("seller", 50, 597).send({ from: accounts[1], gas: 3000000 });
    await contract.methods.joinAuction("seller", 194, 502).send({ from: accounts[2], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 97, 729).send({ from: accounts[3], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 96, 728).send({ from: accounts[4], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 46, 522).send({ from: accounts[5], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 37, 578).send({ from: accounts[6], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 21, 670).send({ from: accounts[7], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 70, 455).send({ from: accounts[8], gas: 3000000 });
    await contract.methods.joinAuction("buyer", 45, 449).send({ from: accounts[9], gas: 3000000 });

    this.getExisingList();

  };

  getExisingList = async () => {
    const { contract } = this.state;

    const sellerList = await contract.methods.getSellerList().call();
    const buyerList = await contract.methods.getBuyerList().call();

    // Update state with the result.
    this.setState({ sellerList: sellerList, buyerList: buyerList });
  }

  sort = async () => {
    const { accounts, contract } = this.state;
    const list = await contract.methods.sortingAlgorithm().call({ from: accounts[0], gas: 3000000 });
    // console.log(list[0])

    this.setState({ sellerList: list[0], buyerList: list[1] });
  }

  setAsksAndBids = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.setAsksAndBidsList().send({ from: accounts[0], gas: 3000000 });
    const asks = await contract.methods.getAsksList().call();
    const bids = await contract.methods.getBidsList().call();

    console.log(asks);
    console.log(bids);
  }

  getQmv = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.getQFunction().send({ from: accounts[0], gas: 3000000 });
    const qmv = await contract.methods.getQmv().call();

    console.log("Qmv: " + qmv)

  }

  reset = async () => {
    const { accounts, contract } = this.state;

    await contract.methods.reset().send({ from: accounts[0], gas: 3000000 });
    this.getExisingList();

  }

  getShift = async () => {
    const { accounts, contract } = this.state;

    await contract.methods.getShift().send({ from: accounts[0], gas: 3000000 });
    console.log("Shift Done");
  }

  getResult = async () => {
    const { accounts, contract } = this.state;

    const result = await contract.methods.getResults().call({ from: accounts[0], gas: 3000000 });
    console.log(result);
  }

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>測試</h1>
        <div style={{ padding: "20px" }}>
          <div>
            輸入角色：
            <input type="text" defaultValue={this.state.inputRole} onChange={(e) => this.setState({ inputRole: e.target.value })} />
          </div>
          <div>
            輸入數量：
            <input type="text" defaultValue={this.state.inputQuantity} onChange={(e) => this.setState({ inputQuantity: e.target.value })} />
          </div>
          <div>
            輸入價格：
            <input type="text" defaultValue={this.state.inputPrice} onChange={(e) => this.setState({ inputPrice: e.target.value })} />
          </div>
        </div>
        <button onClick={this.joinAuction} style={{ margin: "20px" }}>加入拍賣</button>
        <button onClick={this.setDefaultValue} style={{ margin: "20px" }}>加入預設資料</button>
        <button onClick={this.sort} style={{ margin: "20px" }}>Sort</button>
        <button onClick={this.setAsksAndBids} style={{ margin: "20px" }}>Setting</button>
        <button onClick={this.getQmv} style={{ margin: "20px" }}>Qmv</button>
        <button onClick={this.getShift} style={{ margin: "20px" }}>Shift</button>
        <button onClick={this.getResult} style={{ margin: "20px" }}>Result</button>
        <button onClick={this.reset} style={{ margin: "20px" }}>Reset</button>
        <div>賣家清單{this.state.sellerList.map(seller => <p key={seller.addr}>{seller.addr} {"=>"}Quantity: {seller.quantity} {","}Price: {seller.price} </p>)}</div>
        <div>買家清單{this.state.buyerList.map(buyer => <p key={buyer.addr}>{buyer.addr} {"=>"}Quantity: {buyer.quantity} {","}Price: {buyer.price} </p>)}</div>

      </div>
    );
  }
}

export default App;
