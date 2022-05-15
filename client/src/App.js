import React, { Component } from "react";
import DoubleAuctionContract from "./contracts/DoubleAuction.json";
// import getWeb3 from "./getWeb3";
import Web3 from "web3";
import "./App.css";

class App extends Component {
  state = { sellerList: [], buyerList: [], inputRole: "seller", inputQuantity: 149, inputPrice: 619, web3: null, accounts: null, contract: null, gridPrice: 800 };

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
    const { inputRole, inputQuantity, inputPrice } = this.state;

    if (window.ethereum) {

      // res[0] for fetching a first wallet
      await window.ethereum
        .request({ method: "wallet_requestPermissions", params: [{ eth_accounts: {} }] })
        .then(() => window.ethereum.request({ method: "eth_requestAccounts" }))
        .then((res) => {
          this.joinAuctionFunction(inputRole, inputQuantity, inputPrice, res[0]);
        });
      // .then((res) => console.log(res[0]))

    } else {
      alert("請下載 metamask !!");
    }

    this.getExisingList();
  }

  setDefaultValue = async () => {
    const { accounts } = this.state;

    // await this.joinAuctionFunction("seller", 149, 618, accounts[0]);
    await this.joinAuctionFunction("seller", 50, 597, accounts[1]);
    await this.joinAuctionFunction("seller", 194, 502, accounts[2]);
    await this.joinAuctionFunction("seller", 194, 773, accounts[3]);
    await this.joinAuctionFunction("seller", 190, 772, accounts[4]);
    await this.joinAuctionFunction("seller", 86, 601, accounts[5]);
    await this.joinAuctionFunction("seller", 66, 647, accounts[6]);
    await this.joinAuctionFunction("seller", 33, 724, accounts[7]);
    await this.joinAuctionFunction("seller", 136, 546, accounts[8]);
    await this.joinAuctionFunction("seller", 82, 541, accounts[9]);
    await this.joinAuctionFunction("buyer", 73, 682, accounts[10]);
    await this.joinAuctionFunction("buyer", 11, 584, accounts[11]);
    await this.joinAuctionFunction("buyer", 77, 450, accounts[12]);
    await this.joinAuctionFunction("buyer", 54, 591, accounts[13]);
    await this.joinAuctionFunction("buyer", 62, 472, accounts[14]);
    await this.joinAuctionFunction("buyer", 67, 465, accounts[15]);
    await this.joinAuctionFunction("buyer", 11, 457, accounts[16]);
    await this.joinAuctionFunction("buyer", 27, 590, accounts[17]);
    await this.joinAuctionFunction("buyer", 98, 486, accounts[18]);
    await this.joinAuctionFunction("buyer", 46, 477, accounts[19]);
    await this.joinAuctionFunction("buyer", 49, 482, accounts[20]);
    await this.joinAuctionFunction("buyer", 91, 414, accounts[21]);
    await this.joinAuctionFunction("buyer", 64, 630, accounts[22]);
    await this.joinAuctionFunction("buyer", 21, 629, accounts[23]);
    await this.joinAuctionFunction("buyer", 99, 473, accounts[24]);
    await this.joinAuctionFunction("buyer", 44, 563, accounts[25]);
    await this.joinAuctionFunction("buyer", 41, 556, accounts[26]);
    await this.joinAuctionFunction("buyer", 56, 750, accounts[27]);
    await this.joinAuctionFunction("buyer", 67, 719, accounts[28]);
    await this.joinAuctionFunction("buyer", 56, 573, accounts[29]);
  };

  joinAuctionFunction = async (_role, _quantity, _price, _account) => {
    const { contract, gridPrice } = this.state;

    await contract.methods.joinAuction(_role, _quantity, _price).send({ from: _account, gas: 3000000 });
    if (_role === "buyer") {
      await contract.methods.deposit().send({ from: _account, value: _quantity * gridPrice, gas: 3000000 });
    }

    this.getExisingList();
  }

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

  getQmv = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.getQFunction().send({ from: accounts[0], gas: 9000000 });
    const qmv = await contract.methods.getQmv().call();

    console.log("Qmv :" + (qmv / 100));

  }

  reset = async () => {
    const { accounts, contract } = this.state;

    await contract.methods.reset().send({ from: accounts[0], gas: 3000000 });
    this.getExisingList();

  }

  getShift = async () => {
    const { accounts, contract } = this.state;

    await contract.methods.getShift().send({ from: accounts[0], gas: 9000000 });
    console.log("Shift Done !!!");
  }

  getResult = async () => {
    const { accounts, contract } = this.state;

    const result = await contract.methods.getResults().call({ from: accounts[0], gas: 3000000 });
    console.log(result);

    const statistics = await contract.methods.getStatistics().call({ from: accounts[0], gas: 3000000 });
    console.log("Avg: " + statistics[0] + "\tMin: " + statistics[1] + "\tMax: " + statistics[2])
  }

  settlement = async () => {
    const { accounts, contract } = this.state;

    await contract.methods.settlement().send({ from: accounts[0], gas: 3000000 });
    console.log("Settlement Done !!!");
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
        <button onClick={this.getQmv} style={{ margin: "20px" }}>Qmv</button>
        <button onClick={this.getShift} style={{ margin: "20px" }}>Shift & Match</button>
        <button onClick={this.getResult} style={{ margin: "20px" }}>Result</button>
        <button onClick={this.settlement} style={{ margin: "20px" }}>Settlement</button>
        <button onClick={this.reset} style={{ margin: "20px" }}>Reset</button>
        <div>賣家數量：{this.state.sellerList.length} 買家數量：{this.state.buyerList.length}</div>
        <br />
        <div>賣家清單{this.state.sellerList.map(seller => <p key={seller.addr}>{seller.addr} {"=>"}Quantity: {seller.quantity} {","}Price: {seller.price} </p>)}</div>
        <div>買家清單{this.state.buyerList.map(buyer => <p key={buyer.addr}>{buyer.addr} {"=>"}Quantity: {buyer.quantity} {","}Price: {buyer.price} </p>)}</div>

      </div>
    );
  }
}

export default App;
