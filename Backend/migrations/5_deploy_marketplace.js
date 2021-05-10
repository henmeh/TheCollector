const Marketplace = artifacts.require("Marketplace");
const TheCollector = artifacts.require("TheCollector")
const Reward = artifacts.require("Reward");


module.exports =  function (deployer) {
  deployer.deploy(Marketplace, TheCollector.address, Reward.address);
};