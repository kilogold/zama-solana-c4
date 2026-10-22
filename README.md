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

## Working on it

- `workspace.dsl` is the model. Pushing to `main` rebuilds the site.
- View locally: `structurizr local .`, then open http://localhost:8080.
- `export-mermaid.sh` regenerates `mermaid/`, one Mermaid file per view, themed for a dark page.
