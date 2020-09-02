const Register = artifacts.require("Register");
const RideShare = artifacts.require("RideShare");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Register).then(function() {
    return deployer.deploy(RideShare, Register.address);
  });
};
