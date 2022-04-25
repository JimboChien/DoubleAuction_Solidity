var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var DoubleAuction = artifacts.require("./DoubleAuction.sol");

module.exports = function (deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(DoubleAuction);
};
