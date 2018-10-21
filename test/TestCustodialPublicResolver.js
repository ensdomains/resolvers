const ENS = artifacts.require('@ensdomains/ens/contracts/ENSRegistry.sol');
const CustodialPublicResolver = artifacts.require('CustodialPublicResolver.sol');

const namehash = require('eth-ens-namehash');
const ethutil = require('ethereumjs-util');
const Buffer = require('buffer');

contract('CustodialPublicResolver', function (accounts) {

    let node;
    let ens, resolver;

    beforeEach(async () => {
        node = namehash.hash('eth');
        ens = await ENS.new();
        resolver = await CustodialPublicResolver.new(ens.address);
        await ens.setSubnodeOwner(0, web3.sha3('eth'), accounts[0], {from: accounts[0]});
    });

    it.only('should set address for', async () => {
        let data = '0x' + Buffer.concat([node, accounts[1]]).toString('hex');

        console.log(data);

        // let sig = createSignature(accounts[0], data);

        // console.log(sig);

        // await resolver.setAddrFor(node, accounts[1], sig, {from: accounts[0]});
        // assert.equal(await resolver.addr(node), accounts[1]);
    });


});


async function createSignature(account, data) {
    let sig = (await web3.eth.sign(accounts[0], data)).slice(2);

    // let r = ethutil.toBuffer('0x' + sig.substring(0, 64));
    // let s = ethutil.toBuffer('0x' + sig.substring(64, 128));
    // let v = ethutil.toBuffer(parseInt(sig.substring(128, 130), 16) + 27);
    //
    // return '0x' + Buffer.concat([v, r, s]).toString('hex');
}