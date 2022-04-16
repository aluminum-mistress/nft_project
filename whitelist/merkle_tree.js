//<script src="https://cdn.jsdelivr.net/npm/merkletreejs@latest/merkletree.js"></script>
//<script src="https://cdn.jsdelivr.net/npm/keccak256@latest/keccak256.js"></script>


const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');

let whitelistAddress = require('./whitelist.json')


const leafNodes = whitelistAddress.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs: true});

const rootHash = merkleTree.getRoot();
const rootHash_Str = '0x' + rootHash.toString('hex')

const addressIndex = whitelistAddress.indexOf("0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db")
const hexProof = merkleTree.getHexProof(leafNodes[addressIndex])


console.log('whitelist merkle tree\n', merkleTree.toString());
console.log('')
console.log('root hash:', rootHash_Str)
console.log('')
console.log("address_index:", addressIndex)
console.log('')
console.log(JSON.stringify(hexProof,null,1))

/* empty bytes32
[
    "0x0000000000000000000000000000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000000000000000000000000000000"
]
*/

