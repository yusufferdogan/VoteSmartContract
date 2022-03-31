require('dotenv').config();

const {
  BN, // Big Number support
  constants, // Common constants, like the zero address and largest integers
  expectEvent, // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const _contract_1 = artifacts.require(process.env.CONTRACT_1_NAME);

contract(process.env.CONTRACT_1_NAME, ([sender, receiver]) => {
  let contract_1;
  const value = new BN(1);

  // Hook that autoruns before each test function
  beforeEach('should setup the contract instance', async () => {
    // Set the contract
    contract_1 = await _contract_1.deployed();
  });

  it('the token name should be correct', async () => {
    const name = await contract_1.name();

    assert.equal(
      name,
      process.env.CONTRACT_1_TOKEN_NAME,
      'The token name must be valid.'
    );
  });

  it('the token symbol should be correct', async () => {
    const symbol = await contract_1.symbol();

    assert.equal(
      symbol,
      process.env.CONTRACT_1_TOKEN_SYMBOL,
      'The token symbol must be valid.'
    );
  });

  it('the token decimal should be correct', async () => {
    const decimals = (await contract_1.decimals()).toNumber();

    assert.equal(
      decimals,
      process.env.CONTRACT_1_TOKEN_DECIMAL,
      'The token decimal must be valid.'
    );
  });

  it('the token supply should be correct', async () => {
    const supply = (await contract_1.totalSupply()).toNumber();

    assert.equal(
      supply,
      process.env.CONTRACT_1_TOKEN_SUPPLY,
      'The token supply must be valid.'
    );
  });

  it('reverts when transferring tokens to the zero address', async () => {
    // Conditions that trigger a require statement can be precisely tested
    await expectRevert(
      contract_1.transfer(constants.ZERO_ADDRESS, value, {
        from: sender,
      }),
      'ERC20: transfer to the zero address'
    );
  });

  it('emits a Transfer event on successful transfers', async () => {
    const receipt = await contract_1.transfer(receiver, value, {
      from: sender,
    });

    // Event assertions can verify that the arguments are the expected ones
    expectEvent(receipt, 'Transfer', {
      from: sender,
      to: receiver,
      value: value,
    });
  });
});
