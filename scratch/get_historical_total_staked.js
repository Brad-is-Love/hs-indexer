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

async function checkHistoricalTotalStaked() {
  try {
    const totalStaked = await client.readContract({
      address,
      abi,
      functionName: 'totalStaked',
      blockNumber: targetBlock
    });
    console.log(`On-chain totalStaked at block ${targetBlock}: ${totalStaked.toString()}`);
  } catch (err) {
    console.error("Error reading contract:", err);
  }
}

checkHistoricalTotalStaked();
