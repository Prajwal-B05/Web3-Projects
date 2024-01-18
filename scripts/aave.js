const ethers = require('ethers');

async function executeTransaction() {
  try {
    // Replace the following values with your actual ones
    const privateKey = '35ed289b8b2ffc0ac1519cc607034230f4e38aba1de187a649912fd157022673';
    const aaveContractAddress = '0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951';
    const erc20TokenAddress = '0x3FfAf50D4F4E96eB78f2407c090b72e86eCaed24';
    const depositAmount = ethers.utils.parseUnits('1', 'ether'); // Use a recognized unit type

    // Connect to an Ethereum node using Infura (replace with your Infura API key)
    const infuraApiKey = '3a34de4956c84a2493144b1edda855bf';
    const provider = new ethers.providers.JsonRpcProvider(`https://sepolia.infura.io/v3/${infuraApiKey}`);

    // Create a wallet instance using your private key
    const wallet = new ethers.Wallet(privateKey, provider);

    // Create a contract instance for Aave
    const aaveContract = new ethers.Contract(
      aaveContractAddress,
      ['function deposit(address, uint256)'],
      wallet
    );

    // Call the deposit function
    const tx = await aaveContract.deposit(erc20TokenAddress, depositAmount);

    console.log('Transaction Hash:', tx.hash);
    const receipt = await tx.wait();
    console.log('Transaction Receipt:', receipt);
  } catch (error) {
    console.error('Transaction Error:', error);
  }
}

// Call the executeTransaction function
executeTransaction();
