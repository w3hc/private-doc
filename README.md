# Private Doc

Medusa client contract for [Gov Proposal Editor](https://github.com/w3hc/gov-proposal-editor).

## Deployment

PrivateDoc deployed at [0x0eEE41a9efC4aaCfAF68B647b7d0c61F45047010](https://goerli.arbiscan.io/address/0x0eEE41a9efC4aaCfAF68B647b7d0c61F45047010#code) ✅

```sh
npm run clear && npx hardhat run scripts/deploy.ts --network arbitrum-goerli
```

Verifying NFT ownership (`balanceOf`):

```solidity
(bool success, bytes memory check) = nft.call(abi.encodeWithSignature("balanceOf(address)", msg.sender));

if (!success || check[0] == 0) {
    revert InsufficentFunds();
}
```

Medusa docs: https://docs.medusanet.xyz/developers/networks/arbitrum