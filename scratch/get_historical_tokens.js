import { createPublicClient, http } from 'viem';
import { harmonyOne } from 'viem/chains';

const client = createPublicClient({
  chain: harmonyOne,
  transport: http('https://api.harmony.one')
});

const address = "0xc71D7C069Ae96794c5d6d54ff04754D2832601c3";
const targetBlock = 58914957n;

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
  }
];

async function checkHistoricalTokens() {
  console.log(`Fetching historical token states at block ${targetBlock}...`);
  const balances = [];
  
  for (let i = 0; i <= 22; i++) {
    try {
      const info = await client.readContract({
        address,
        abi,
        functionName: 'tokenIdToInfo',
        args: [BigInt(i)],
        blockNumber: targetBlock
      });
      
      const [staked, unstaked, withdrawEpoch] = info;
      console.log(`Token ${i}: Staked = ${staked.toString()}`);
      balances.push(staked.toString());
    } catch (e) {
      console.log(`Token ${i}: Failed to read`, e);
    }
  }
  
  console.log("\nCopy-pasteable initialBalances array:");
  console.log(JSON.stringify(balances, null, 2));
}

checkHistoricalTokens();
