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
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "tokenId",
        "type": "uint256"
      }
    ],
    "name": "ownerOf",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

async function checkHistoricalTokens() {
  console.log(`Fetching all historical token states up to 100 at block ${targetBlock}...`);
  const initialTokenHolders = [];
  const initialBalances = [];
  
  let sumStaked = BigInt(0);
  for (let i = 0; i <= 100; i++) {
    try {
      const info = await client.readContract({
        address,
        abi,
        functionName: 'tokenIdToInfo',
        args: [BigInt(i)],
        blockNumber: targetBlock
      });
      
      const [staked, unstaked, withdrawEpoch] = info;
      if (staked > 0n || unstaked > 0n) {
        let owner = "0x0000000000000000000000000000000000000000";
        try {
          owner = await client.readContract({
            address,
            abi,
            functionName: 'ownerOf',
            args: [BigInt(i)],
            blockNumber: targetBlock
          });
        } catch (err) {}
        
        console.log(`Token ${i}: Owner = ${owner}, Staked = ${staked.toString()}`);
        initialTokenHolders.push(owner);
        initialBalances.push(staked.toString());
        sumStaked += staked;
      }
    } catch (e) {
      // Token doesn't exist
      break;
    }
  }
  
  console.log(`\nTotal Staked Summed: ${sumStaked.toString()}`);
  console.log("\nCopy-pasteable initialTokenHolders:");
  console.log(JSON.stringify(initialTokenHolders, null, 2));
  console.log("\nCopy-pasteable initialBalances:");
  console.log(JSON.stringify(initialBalances, null, 2));
}

checkHistoricalTokens();
