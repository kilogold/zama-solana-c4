# Zama FHEVM on Solana: C4 model

A C4 model of the Solana port of Zama FHEVM, from system landscape down to components, marking which parts are Solana-specific.

- **Code of record:** [zama-ai/fhevm `feature/solana` @ `50782a4ad`](https://github.com/zama-ai/fhevm/tree/50782a4ad01e0642b15b4841b1fa5c0792cf1636). Every element links to its code at that commit.
- **Site:** https://kilogold.github.io/zama-solana-c4/

## Colours

- **Green:** Solana-specific: `solana/programs`, `solana/crates`, `solana/clients`, `sdk/js-sdk/src/solana`.
- **Amber:** the Solana-facing part of an off-chain service.
- **Grey:** everything else.

## Views

| View | Level | Shows |
| --- | --- | --- |
| `L1-Landscape` | System | The Solana host among Zama's systems |
| `L2-Host` | Container | What the Solana host is made of |
| `L2-Seams` | Container | The Solana-facing parts of the off-chain services |
| `L3-zama-host` | Component | `zama-host` instruction families |
| `L3-Shared-crates` | Component | The shared crates and who compiles them in |
| `L3-js-sdk` | Component | The Solana client SDK |
| `F1-Shielding` | Dynamic | Shield public USDC into a confidential balance, in one transaction |
| `F2-Transfer` | Dynamic | Transfer an encrypted amount, after an off-chain input proof |
| `F3a-Close-ProveZero` | Dynamic | Proposed option A: close an empty token account with a certificate that its balance is 0 |
| `F3b-Close-BurnAll` | Dynamic | Proposed option B: burn the whole balance, then redeem it and close the account in one transaction |
| `F3-StoreClosed` | Dynamic | Proposed: after F3a or F3b closed a Store, decrypt its history from the `StoreClosed` event |

## Working on it

- `workspace.dsl` is the model. Pushing to `main` rebuilds the site.
- View locally: `structurizr local .`, then open http://localhost:8080.
- `export-mermaid.sh` regenerates `mermaid/`, one Mermaid file per view, themed for a dark page.
