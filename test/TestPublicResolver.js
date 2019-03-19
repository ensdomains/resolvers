const ENS = artifacts.require('@ensdomains/ens/contracts/ENSRegistry.sol');
const PublicResolver = artifacts.require('PublicResolver.sol');

const utils = require('./helpers/Utils.js');
const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

contract('PublicResolver', function (accounts) {

    let node;
    let ens, resolver;

    beforeEach(async () => {
        node = namehash.hash('eth');
        ens = await ENS.new();
        resolver = await PublicResolver.new(ens.address);
        await ens.setSubnodeOwner('0x0', sha3('eth'), accounts[0], {from: accounts[0]});
    });

    describe('fallback function', async () => {

        it('forbids calls to the fallback function with 0 value', async () => {
            try {
                await web3.eth.sendTransaction({
                    from: accounts[0],
                    to: resolver.address,
                    gas: 3000000
                })

            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('transfer did not fail');
        });

        it('forbids calls to the fallback function with 1 value', async () => {
            try {
                await web3.eth.sendTransaction({
                    from: accounts[0],
                    to: resolver.address,
                    gas: 3000000,
                    value: 1
                })
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('transfer did not fail');
        });
    });

    describe('supportsInterface function', async () => {

        it('supports known interfaces', async () => {
            assert.equal(await resolver.supportsInterface("0x3b3b57de"), true);
            assert.equal(await resolver.supportsInterface("0x691f3431"), true);
            assert.equal(await resolver.supportsInterface("0x2203ab56"), true);
            assert.equal(await resolver.supportsInterface("0xc8690233"), true);
            assert.equal(await resolver.supportsInterface("0x59d1d43c"), true);
            assert.equal(await resolver.supportsInterface("0xbc1c58d1"), true);
        });

        it('does not support a random interface', async () => {
            assert.equal(await resolver.supportsInterface("0x3b3b57df"), false);
        });
    });


    describe('addr', async () => {

        it('permits setting address by owner', async () => {
            await resolver.setAddr(node, accounts[1], {from: accounts[0]});
            assert.equal(await resolver.addr(node), accounts[1]);
        });

        it('can overwrite previously set address', async () => {
            await resolver.setAddr(node, accounts[1], {from: accounts[0]});
            assert.equal(await resolver.addr(node), accounts[1]);

            await resolver.setAddr(node, accounts[0], {from: accounts[0]});
            assert.equal(await resolver.addr(node), accounts[0]);
        });

        it('can overwrite to same address', async () => {
            await resolver.setAddr(node, accounts[1], {from: accounts[0]});
            assert.equal(await resolver.addr(node), accounts[1]);

            await resolver.setAddr(node, accounts[1], {from: accounts[0]});
            assert.equal(await resolver.addr(node), accounts[1]);
        });

        it('forbids setting new address by non-owners', async () => {

            try {
                await resolver.setAddr(node, accounts[1], {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('forbids writing same address by non-owners', async () => {

            await resolver.setAddr(node, accounts[1], {from: accounts[0]});

            try {
                await resolver.setAddr(node, accounts[1], {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('writing did not fail');
        });

        it('forbids overwriting existing address by non-owners', async () => {

            await resolver.setAddr(node, accounts[1], {from: accounts[0]});

            try {
                await resolver.setAddr(node, accounts[0], {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('overwriting did not fail');
        });

        it('returns zero when fetching nonexistent addresses', async () => {
            assert.equal(await resolver.addr(node), '0x0000000000000000000000000000000000000000');
        });
    });

    describe('name', async () => {

        it('permits setting name by owner', async () => {
            await resolver.setName(node, 'name1', {from: accounts[0]});
            assert.equal(await resolver.name(node), 'name1');
        });

        it('can overwrite previously set names', async () => {
            await resolver.setName(node, 'name1', {from: accounts[0]});
            assert.equal(await resolver.name(node), 'name1');

            await resolver.setName(node, 'name2', {from: accounts[0]});
            assert.equal(await resolver.name(node), 'name2');
        });

        it('forbids setting name by non-owners', async () => {
            try {
                await resolver.setName(node, 'name2', {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }
        });

        it('returns empty when fetching nonexistent name', async () => {
            assert.equal(await resolver.name(node), '');
        });
    });

    describe('pubkey', async () => {

        it('returns empty when fetching nonexistent values', async () => {

            let result = await resolver.pubkey(node);
            assert.equal(result[0], "0x0000000000000000000000000000000000000000000000000000000000000000");
            assert.equal(result[1], "0x0000000000000000000000000000000000000000000000000000000000000000");
        });

        it('permits setting public key by owner', async () => {
            let x = '0x1000000000000000000000000000000000000000000000000000000000000000';
            let y = '0x2000000000000000000000000000000000000000000000000000000000000000';

            await resolver.setPubkey(node, x, y, {from: accounts[0]});

            let result = await resolver.pubkey(node);
            assert.equal(result[0], x);
            assert.equal(result[1], y);
        });

        it('can overwrite previously set value', async () => {
            await resolver.setPubkey(
                node,
                '0x1000000000000000000000000000000000000000000000000000000000000000',
                '0x2000000000000000000000000000000000000000000000000000000000000000',
                {from: accounts[0]}
            );

            let x = '0x3000000000000000000000000000000000000000000000000000000000000000';
            let y = '0x4000000000000000000000000000000000000000000000000000000000000000';
            await resolver.setPubkey(node, x, y, {from: accounts[0]});

            let result = await resolver.pubkey(node);
            assert.equal(result[0], x);
            assert.equal(result[1], y);
        });

        it('can overwrite to same value', async () => {
            let x = '0x1000000000000000000000000000000000000000000000000000000000000000';
            let y = '0x2000000000000000000000000000000000000000000000000000000000000000';

            await resolver.setPubkey(node, x, y, {from: accounts[0]});
            await resolver.setPubkey(node, x, y, {from: accounts[0]});

            let result = await resolver.pubkey(node);
            assert.equal(result[0], x);
            assert.equal(result[1], y);
        });

        it('forbids setting value by non-owners', async () => {

            try {
                await resolver.setPubkey(
                    node,
                    '0x1000000000000000000000000000000000000000000000000000000000000000',
                    '0x2000000000000000000000000000000000000000000000000000000000000000',
                    {from: accounts[1]}
                );
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('forbids writing same value by non-owners', async () => {
            let x = '0x1000000000000000000000000000000000000000000000000000000000000000';
            let y = '0x2000000000000000000000000000000000000000000000000000000000000000';

            await resolver.setPubkey(node, x, y, {from: accounts[0]});

            try {
                await resolver.setPubkey(node, x, y, {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('forbids overwriting existing value by non-owners', async () => {
            await resolver.setPubkey(
                node,
                '0x1000000000000000000000000000000000000000000000000000000000000000',
                '0x2000000000000000000000000000000000000000000000000000000000000000',
                {from: accounts[0]}
            );

            try {
                await resolver.setPubkey(
                    node,
                    '0x3000000000000000000000000000000000000000000000000000000000000000',
                    '0x4000000000000000000000000000000000000000000000000000000000000000',
                    {from: accounts[1]}
                 );
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });
    });

    describe('ABI', async () => {
        it('returns a contentType of 0 when nothing is available', async () => {
            let result = await resolver.ABI(node, 0xFFFFFFFF);
            assert.equal(result[0], 0);
        });

        it('returns an ABI after it has been set', async () => {
            await resolver.setABI(node, 0x1, '0x666f6f', {from: accounts[0]})
            let result = await resolver.ABI(node, 0xFFFFFFFF);
            assert.deepEqual([result[0].toNumber(), result[1]], [1, "0x666f6f"]);
        });

        it('returns the first valid ABI', async () => {
            await resolver.setABI(node, 0x2, "0x666f6f", {from: accounts[0]});
            await resolver.setABI(node, 0x4, "0x626172", {from: accounts[0]});

            let result = await resolver.ABI(node, 0x7);
            assert.deepEqual([result[0].toNumber(), result[1]], [2, "0x666f6f"]);

            result = await resolver.ABI(node, 0x5);
            assert.deepEqual([result[0].toNumber(), result[1]], [4, "0x626172"]);
        });

        it('allows deleting ABIs', async () => {
            await resolver.setABI(node, 0x1, "0x666f6f", {from: accounts[0]})
            let result = await resolver.ABI(node, 0xFFFFFFFF);
            assert.deepEqual([result[0].toNumber(), result[1]], [1, "0x666f6f"]);

            await resolver.setABI(node, 0x1, "0x", {from: accounts[0]})
            result = await resolver.ABI(node, 0xFFFFFFFF);
            assert.deepEqual([result[0].toNumber(), result[1]], [0, null]);
        });

        it('rejects invalid content types', async () => {
            try {
                await resolver.setABI(node, 0x3, "0x12", {from: accounts[0]})
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('forbids setting value by non-owners', async () => {

            try {
                await resolver.setABI(node, 0x1, "0x666f6f", {from: accounts[1]})
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });
    });

    describe('text', async () => {
        var url = "https://ethereum.org";
        var url2 = "https://github.com/ethereum";

        it('permits setting text by owner', async () => {
            await resolver.setText(node, "url", url, {from: accounts[0]});
            assert.equal(await resolver.text(node, "url"), url);
        });

        it('can overwrite previously set text', async () => {
            await resolver.setText(node, "url", url, {from: accounts[0]});
            assert.equal(await resolver.text(node, "url"), url);

            await resolver.setText(node, "url", url2, {from: accounts[0]});
            assert.equal(await resolver.text(node, "url"), url2);
        });

        it('can overwrite to same text', async () => {
            await resolver.setText(node, "url", url, {from: accounts[0]});
            assert.equal(await resolver.text(node, "url"), url);

            await resolver.setText(node, "url", url, {from: accounts[0]});
            assert.equal(await resolver.text(node, "url"), url);
        });

        it('forbids setting new text by non-owners', async () => {
            try {
                await resolver.setText(node, "url", url, {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('forbids writing same text by non-owners', async () => {
            await resolver.setText(node, "url", url, {from: accounts[0]});

            try {
                await resolver.setText(node, "url", url, {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });
    });

    describe('contenthash', async () => {

        it('permits setting contenthash by owner', async () => {
            await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000001', {from: accounts[0]});
            assert.equal(await resolver.contenthash(node), '0x0000000000000000000000000000000000000000000000000000000000000001');
        });

        it('can overwrite previously set contenthash', async () => {
            await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000001', {from: accounts[0]});
            assert.equal(await resolver.contenthash(node), '0x0000000000000000000000000000000000000000000000000000000000000001');

            await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000002', {from: accounts[0]});
            assert.equal(await resolver.contenthash(node), '0x0000000000000000000000000000000000000000000000000000000000000002');
        });

        it('can overwrite to same contenthash', async () => {
            await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000001', {from: accounts[0]});
            assert.equal(await resolver.contenthash(node), '0x0000000000000000000000000000000000000000000000000000000000000001');

            await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000002', {from: accounts[0]});
            assert.equal(await resolver.contenthash(node), '0x0000000000000000000000000000000000000000000000000000000000000002');
        });

        it('forbids setting contenthash by non-owners', async () => {
            try {
                await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000001', {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('forbids writing same contenthash by non-owners', async () => {
            await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000001', {from: accounts[0]});

            try {
                await resolver.setContenthash(node, '0x0000000000000000000000000000000000000000000000000000000000000001', {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('returns empty when fetching nonexistent contenthash', async () => {
            assert.equal(
                await resolver.contenthash(node),
                null
            );
        });
    });

    describe('implementsInterface', async () => {
        it('permits setting interface by owner', async () => {
            await resolver.setInterface(node, "0x12345678", accounts[0], {from: accounts[0]});
            assert.equal(await resolver.interfaceImplementer(node, "0x12345678"), accounts[0]);
        });

        it('can update previously set interface', async () => {
            await resolver.setInterface(node, "0x12345678", resolver.address, {from: accounts[0]});
            assert.equal(await resolver.interfaceImplementer(node, "0x12345678"), resolver.address);
        });

        it('forbids setting interface by non-owner', async () => {
            try {
                await resolver.setInterface(node, '0x12345678', accounts[1], {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('returns 0 when fetching unset interface', async () => {
            assert.equal(await resolver.interfaceImplementer(namehash.hash("foo"), "0x12345678"), "0x0000000000000000000000000000000000000000");
        });

        it('falls back to calling implementsInterface on addr', async () => {
            // Set addr to the resolver itself, since it has interface implementations.
            await resolver.setAddr(node, resolver.address, {from: accounts[0]});
            // Check the ID for `addr(bytes32)`
            assert.equal(await resolver.interfaceImplementer(node, "0x3b3b57de"), resolver.address);
        });

        it('returns 0 on fallback when target contract does not implement interface', async () => {
            // Check an imaginary interface ID we know it doesn't support.
            assert.equal(await resolver.interfaceImplementer(node, "0x00000000"), "0x0000000000000000000000000000000000000000");
        });

        it('returns 0 on fallback when target contract does not support implementsInterface', async () => {
            // Set addr to the ENS registry, which doesn't implement supportsInterface.
            await resolver.setAddr(node, ens.address, {from: accounts[0]});
            // Check the ID for `supportsInterface(bytes4)`
            assert.equal(await resolver.interfaceImplementer(node, "0x01ffc9a7"), "0x0000000000000000000000000000000000000000");
        });

        it('returns 0 on fallback when target is not a contract', async () => {
            // Set addr to an externally owned account.
            await resolver.setAddr(node, accounts[0], {from: accounts[0]});
            // Check the ID for `supportsInterface(bytes4)`
            assert.equal(await resolver.interfaceImplementer(node, "0x01ffc9a7"), "0x0000000000000000000000000000000000000000");
        });
    });

    describe('authorisations', async () => {
        it('permits authorisations to be set', async () => {
            await resolver.setAuthorisation(node, accounts[1], true, {from: accounts[0]});
            assert.equal(await resolver.authorisations(node, accounts[0], accounts[1]), true);
        });

        it('permits authorised users to make changes', async () => {
            await resolver.setAuthorisation(node, accounts[1], true, {from: accounts[0]});
            assert.equal(await resolver.authorisations(node, await ens.owner(node), accounts[1]), true);
            await resolver.setAddr(node, accounts[1], {from: accounts[1]});
            assert.equal(await resolver.addr(node), accounts[1]);
        });

        it('permits authorisations to be cleared', async () => {
            await resolver.setAuthorisation(node, accounts[1], false, {from: accounts[0]});
            try {
                await resolver.setAddr(node, accounts[0], {from: accounts[1]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('permits non-owners to set authorisations', async () => {
            await resolver.setAuthorisation(node, accounts[2], true, {from: accounts[1]});

            // The authorisation should have no effect, because accounts[1] is not the owner.
            try {
                await resolver.setAddr(node, accounts[0], {from: accounts[2]});
            } catch (error) {
                return utils.ensureException(error);
            }

            assert.fail('setting did not fail');
        });

        it('checks the authorisation for the current owner', async () => {
            await resolver.setAuthorisation(node, accounts[2], true, {from: accounts[1]});
            await ens.setOwner(node, accounts[1], {from: accounts[0]});

            await resolver.setAddr(node, accounts[0], {from: accounts[2]});
            assert.equal(await resolver.addr(node), accounts[0]);
        });
    });
});
