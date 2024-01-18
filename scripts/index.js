const {ethers} = require('ethers');


const provider = new ethers.providers.JsonRpcProvider('https://bsc-testnet.publicnode.com');


const contractAddress = '0xA1A3fe72C998200eff863E3Fd2106Db9a1268c1b'; 
const PrivateKey = '35ed289b8b2ffc0ac1519cc607034230f4e38aba1de187a649912fd157022673'; 

const targetAddress = '0x03f716E5C9773C7758ca013755874520Cf17CFD3';
const dataToDelegate = ethers.utils.formatBytes32String('Transfer');
console.log('Formatted Data:', dataToDelegate);

const wallet = new ethers.Wallet(PrivateKey, provider);


const contract = new ethers.Contract(contractAddress, ['function transferFunds(address,bytes)'], wallet);




const encodedParams = ethers.utils.defaultAbiCoder.encode(['address', 'bytes'], [targetAddress, dataToDelegate]);

const functionSelector = contract.interface.getSighash('transferFunds').substring(0, 10);



const payload = functionSelector + encodedParams.substring(2);
console.log('Constructed Payload:', payload);


const gasLimit = 5000000;


const gasPrice = ethers.utils.parseUnits('5', 'gwei');
const value = ethers.utils.parseUnits('1', 'wei');


const transaction = {
    gasLimit: ethers.BigNumber.from(gasLimit),
    gasPrice: gasPrice,
    to: contractAddress,
    data: payload,
    value : value,
};


wallet.sendTransaction(transaction)
    .then((tx) => {
        console.log('Transaction Hash:', tx.hash);
        return tx.wait();
    })
    .then((receipt) => {
        console.log('Transaction Receipt:', receipt);
    })
    .catch((error) => {
        console.error('Transaction Error:', error);
    });


    txn_hash = 0x03f716E5C9773C7758ca013755874520Cf17CFD3 ;//transacftion failed due to insuffiecient funds