import { createPublicClient, http } from 'viem';
import { harmonyOne } from 'viem/chains';

const client = createPublicClient({
  chain: harmonyOne,
  transport: http('https://api.harmony.one')
});

const address = "0xc71D7C069Ae96794c5d6d54ff04754D2832601c3";

const abi = [
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "tokenIdToInfo",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "staked",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "unstaked",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "withdrawEpoch",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "totalStaked",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

async function checkAllTokens() {
  try {
    const totalStakedOnChain = await client.readContract({
      address,
      abi,
      functionName: 'totalStaked'
    });
    console.log(`On-Chain totalStaked: ${totalStakedOnChain.toString()}`);
    
    let sumStaked = BigInt(0);
    for (let i = 0; i <= 25; i++) {
      try {
        const info = await client.readContract({
          address,
          abi,
          functionName: 'tokenIdToInfo',
          args: [BigInt(i)]
        });
        
        const [staked, unstaked, withdrawEpoch] = info;
        console.log(`Token ${i}: Staked = ${staked.toString()}, Unstaked = ${unstaked.toString()}`);
        sumStaked += staked;
      } catch (e) {
        console.log(`Token ${i}: Failed to read`);
      }
    }
    console.log(`\nSum of Staked (Tokens 0-25): ${sumStaked.toString()}`);
  } catch (err) {
    console.error("Error connecting or reading:", err);
  }
}

checkAllTokens();
