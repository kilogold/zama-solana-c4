/*
 * C4 model of the Solana port of Zama FHEVM.
 *
 * Code of record: zama-ai/fhevm feature/solana @ 50782a4ad01e0642b15b4841b1fa5c0792cf1636.
 * Every element links to its code at that commit.
 *
 * Scope tags (one per element, drawn by the styles at the end):
 *   Solana        - in review scope: solana/programs, solana/crates, solana/clients, sdk/js-sdk/src/solana
 *   Seam          - the Solana-facing part of an off-chain service, reviewed only where it meets the scope
 *   Out of scope  - everything else
 * ("Boundary" would read better than "Seam", but Structurizr reserves it for drawing system boundaries.)
 *
 * Elements and relationships were read from Cargo/package dependencies, imports and module docs at
 * the pin. Relationships marked "I:" in a comment are inferred, with the reason given.
 *
 * Not modelled: test-only code (delegator-vault, runtime-tests, test-kit, test-suite), the demo-dapp,
 * and the program-environment build helper.
 */
workspace "Zama FHEVM on Solana" "C4 model of the Solana port at zama-ai/fhevm@50782a4ad, marking the review scope." {

    !identifiers hierarchical
    !const SRC "https://github.com/zama-ai/fhevm/tree/50782a4ad01e0642b15b4841b1fa5c0792cf1636"

    model {

        user = person "dApp user" "Holds a Solana wallet. Encrypts inputs and signs user-decrypt permits through an app built on the SDKs." {
            tags "Out of scope"
        }
        operator = person "Host operator" "zama-host admin and pausers. Can be a program-controlled signer such as a Squads vault." {
            tags "Out of scope"
        }

        cluster = softwareSystem "Solana cluster" "Validators, JSON-RPC and Yellowstone gRPC. Every component reads it at finalized commitment." {
            tags "Out of scope"
        }

        host = softwareSystem "FHEVM Solana host" "The Solana runtime side of FHEVM: on-chain programs, Rust crates and TypeScript SDKs." {
            tags "Solana"
            url "${SRC}/solana"

            zamaHost = container "zama-host" "Protocol host program: encrypted stores and their ACL/MMR, fhe_execute, input attestations, public-decrypt verification, KMS contexts, HCU metering." "Anchor program" {
                tags "Solana" "Program"
                url "${SRC}/solana/programs/zama-host"

                admin = component "Host administration" "initialize_host_config, set_admin/accept_admin, pause/unpause/set_pauser, set_coprocessor_signers, set_deny_scope, set_grant_deny_list_enabled, HCU limits." "instructions/*.rs, state/host_config.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions"
                }
                transient = component "Transient store" "open_transient_store and close_transient_store: the per-transaction journal of result occurrences and grants." "instructions/transient.rs, state/transient.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions/transient.rs"
                }
                stores = component "Encrypted store" "create_encrypted_store and make_store_handle_public: one host-owned PDA per (program, authority, scope) with named slots and an append-only MMR." "instructions/create_encrypted_store.rs, state/encrypted_store.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/state/encrypted_store.rs"
                }
                execute = component "FHE execution" "fhe_execute: preflight, account table, ordered step walk, store outputs." "instructions/fhe_execute.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions/fhe_execute.rs"
                }
                inputs = component "Input verification" "Verifies the coprocessors' threshold secp256k1 attestation of an external input." "instructions/input_verification.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions/input_verification.rs"
                }
                hcu = component "HCU metering" "Per-transaction HCU and depth caps, and the per-application block meter." "instructions/fhe_execute/hcu, block_cap.rs, state/hcu_*.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions/fhe_execute/hcu"
                }
                events = component "Event transport" "Emits one FheExecutedEvent per execution through Anchor event CPI." "fhe_execute/event_transport.rs, events.rs, event_cpi.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions/fhe_execute/event_transport.rs"
                }
                userDecrypt = component "User-decrypt authorization" "delegate_for_user_decryption, revoke_delegation_for_user_decryption, revoke_permits." "state/user_decryption_delegation.rs, state/permit_invalidation.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/state/user_decryption_delegation.rs"
                }
                publicDecrypt = component "Public-decrypt verification" "verify_public_decrypt: checks a KMS certificate against the KMS context it names." "instructions/verify_public_decrypt.rs, eip712.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/instructions/verify_public_decrypt.rs"
                }
                kmsContexts = component "KMS contexts" "define_kms_context, define_kms_epoch, destroy_kms_context." "state/kms_context.rs" {
                    tags "Solana"
                    url "${SRC}/solana/programs/zama-host/src/state/kms_context.rs"
                }
            }

            group "Reference app programs" {
                token = container "confidential-token" "Confidential token wrapper: wrap, transfer, burn, redeem, disclose." "Anchor program" {
                    tags "Solana" "Program"
                    url "${SRC}/solana/programs/confidential-token"
                }
                batcher = container "confidential-batcher" "Aggregates encrypted deposits per batch and pays each user an encrypted proportional cut (DD-042)." "Anchor program" {
                    tags "Solana" "Program"
                    url "${SRC}/solana/programs/confidential-batcher"
                }
                vault = container "demo-vault" "Public share-mint vault the batcher fronts. Plain SPL, no FHE." "Anchor program" {
                    tags "Solana" "Program"
                    url "${SRC}/solana/programs/demo-vault"
                }
                counter = container "encrypted-counter" "Smallest complete zama-host consumer, written to be copied." "Anchor program" {
                    tags "Solana" "Program"
                    url "${SRC}/solana/programs/encrypted-counter"
                }
                depChain = container "dep-chain" "Load shape: a full-depth dependent FHE chain in one fhe_execute." "Anchor program" {
                    tags "Solana" "Program"
                    url "${SRC}/solana/programs/dep-chain"
                }
            }

            zamaFhe = container "zama-fhe" "App-facing SDK: builds one fhe_execute (FheExecution), resolves its accounts and invokes it by CPI." "Rust crate" {
                tags "Solana" "Library"
                url "${SRC}/solana/crates/zama-fhe"
            }

            shared = container "Shared protocol crates" "One definition of the ACL, permit, request and wire rules, compiled into the host program and the off-chain services." "Rust crates" {
                tags "Solana" "Library"
                url "${SRC}/solana/crates"

                acl = component "zama-solana-acl" "EncryptedStore layout and PDA seeds, MMR history, leaf commitments, decrypt-authorization rules, host chain-id rules." "Rust crate" {
                    tags "Solana"
                    url "${SRC}/solana/crates/zama-solana-acl"
                }
                permit = component "zama-solana-permit" "Canonical user-decrypt permit: strict decoding, canonical text, sRFC 38 envelope, Ed25519 verification." "Rust crate" {
                    tags "Solana"
                    url "${SRC}/solana/crates/zama-solana-permit"
                }
                request = component "zama-solana-request" "Typed user-decrypt request and its form rules." "Rust crate" {
                    tags "Solana"
                    url "${SRC}/solana/crates/zama-solana-request"
                }
                transaction = component "zama-solana-transaction" "Provider-independent resolution of compiled transaction instructions." "Rust crate" {
                    tags "Solana"
                    url "${SRC}/solana/crates/zama-solana-transaction"
                }
                merkleProofs = component "zama-solana-merkle-proofs" "Wire types of the Merkle proof service: CBOR bodies, JSON errors." "Rust crate" {
                    tags "Solana"
                    url "${SRC}/solana/crates/zama-solana-merkle-proofs"
                }
            }

            jsSdk = container "@fhevm/sdk/solana" "Client SDK: encrypt inputs, user and public decryption, permits, delegation, transient store." "TypeScript" {
                tags "Solana" "Library"
                url "${SRC}/sdk/js-sdk/src/solana"

                sdkClients = component "Clients" "createFhevmBaseClient, createFhevmEncryptClient, createFhevmDecryptClient, createFhevmPublicDecryptClient." "clients/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/clients"
                }
                encrypt = component "Input encryption" "encryptInput and submitInputProof." "actions/encryptInput.ts, actions/submitInputProof.ts" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/actions"
                }
                permits = component "Permit" "Builds, renders and validates the user-decrypt permit and its offchain-message envelope." "permit/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/permit"
                }
                sdkUserDecrypt = component "User decryption" "Builds the request, executes it and decodes the response." "userDecrypt/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/userDecrypt"
                }
                sdkPublicDecrypt = component "Public decryption" "decryptPublicValue, publicDecryptCertificate, verifyPublicDecrypt." "actions/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/actions"
                }
                transport = component "Decryption transport" "Posts decryption requests to relayer-http, with deadline and retry." "decryption/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/decryption"
                }
                hostActions = component "Host actions" "Transient store, encrypted store, user-decryption delegation, permit revocation, host KMS reads." "transientStore.ts, encryptedStore.ts, actions/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana"
                }
                cleartext = component "Cleartext mode" "Encrypt and decrypt clients for a cleartext host build." "cleartext/" {
                    tags "Solana"
                    url "${SRC}/sdk/js-sdk/src/solana/cleartext"
                }
            }

            hostClient = container "@fhevm/solana-zama-host" "Codama client for zama-host, plus the version-1 signing and finalized sending every Solana client uses." "TypeScript" {
                tags "Solana" "Library"
                url "${SRC}/solana/clients/zama-host"
            }
            tokenClient = container "@fhevm/confidential-token" "Codama client for confidential-token." "TypeScript" {
                tags "Solana" "Library"
                url "${SRC}/solana/clients/confidential-token"
            }
        }

        coprocessor = softwareSystem "Coprocessor" "Zama's FHE compute network." {
            tags "Out of scope"
            url "${SRC}/coprocessor/fhevm-engine"

            listener = container "Solana host listener" "host-listener's Solana ingestion (solana_listener, solana_adapter, solana_reconstruct) on a solana-host-follower: rebuilds each execution from transaction bytes." "Rust" {
                tags "Seam"
                url "${SRC}/coprocessor/fhevm-engine/host-listener/src"
            }
            merkleService = container "solana-merkle-proof-service" "Indexer rebuilds every encrypted store's leaf record from finalized blocks; server answers inclusion proofs." "Rust" {
                tags "Seam" "Database"
                url "${SRC}/coprocessor/fhevm-engine/solana-merkle-proof-service"
            }
            attestation = container "Input attestation" "gw-listener, zkproof-worker and transaction-sender: verify input proofs and sign the Solana attestation (bytes32 identities, chain-type byte 0x01)." "Rust" {
                tags "Seam"
                url "${SRC}/coprocessor/fhevm-engine/zkproof-worker"
            }
            workers = container "FHE workers" "Scheduler, tfhe-worker, sns-worker." "Rust" {
                tags "Out of scope"
                url "${SRC}/coprocessor/fhevm-engine/tfhe-worker"
            }
        }

        gateway = softwareSystem "Gateway" "Zama's gateway chain contracts." {
            tags "Out of scope"
            url "${SRC}/gateway-contracts"

            inputVerification = container "InputVerification" "verifyProofRequestSolana and verifyProofResponseSolana." "Solidity" {
                tags "Seam"
                url "${SRC}/gateway-contracts/contracts/InputVerification.sol"
            }
        }

        relayer = softwareSystem "Relayer" "Gateway relayer: input proofs and fees." {
            tags "Out of scope"
            url "${SRC}/relayer"

            inputRelay = container "Solana input-proof handler" "Accepts Solana input proofs and calls verifyProofRequestSolana." "Rust" {
                tags "Seam"
                url "${SRC}/relayer/src/gateway/input_handlers.rs"
            }
        }

        relayerHttp = softwareSystem "relayer-http" "Decryption relayer." {
            tags "Out of scope"
            url "${SRC}/relayer-http"

            router = container "Decryption router" "Checks a request's form and validity window, forwards it to every KMS connector and aggregates the answers." "Rust" {
                tags "Seam"
                url "${SRC}/relayer-http/crates/relayer-http/src"
            }
        }

        kmsConnector = softwareSystem "KMS connector" "One per KMS party. The decrypt-authorization authority." {
            tags "Out of scope"
            url "${SRC}/kms-connector"

            endpoint = container "Endpoint" "Receives Solana user and public decryption requests over HTTP and validates their form." "Rust" {
                tags "Seam"
                url "${SRC}/kms-connector/crates/endpoint"
            }
            kmsWorker = container "kms-worker Solana pipeline" "Re-verifies the permit, reads the encrypted store and delegations from the chain, verifies the allow leaf's MMR proof." "Rust" {
                tags "Seam"
                url "${SRC}/kms-connector/crates/kms-worker/src/core/solana"
            }
        }

        kmsCore = softwareSystem "KMS core" "Chain-blind threshold decryption (zama-ai/kms; its solana branch holds the Solana user address)." {
            tags "Out of scope"
        }

        splToken = softwareSystem "SPL Token programs" "Token and Token-2022. Hold the public underlying that confidential-token escrows." {
            tags "Out of scope"
        }

        # People
        user -> host.jsSdk "Encrypts inputs and requests decryptions through an app using"
        user -> host.tokenClient "Moves confidential tokens through an app using"
        operator -> host.zamaHost.admin "Administers"
        operator -> host.zamaHost.kmsContexts "Defines and destroys"

        # Programs
        host.token -> host.zamaFhe "Builds executions with"
        host.batcher -> host.zamaFhe "Builds executions with"
        host.counter -> host.zamaFhe "Builds executions with"
        host.depChain -> host.zamaFhe "Builds executions with"
        host.zamaFhe -> host.zamaHost.execute "Invokes fhe_execute by CPI"
        host.token -> host.zamaHost.stores "Creates encrypted stores by CPI"
        host.batcher -> host.token "Calls confidential_transfer by CPI"
        host.batcher -> host.vault "Deposits and redeems by CPI"
        host.token -> splToken "Escrows the underlying by transfer_checked CPI"

        # Inside zama-host
        host.zamaHost.execute -> host.zamaHost.transient "Records results and grants in"
        host.zamaHost.execute -> host.zamaHost.inputs "Verifies external inputs with"
        host.zamaHost.execute -> host.zamaHost.hcu "Charges HCU to"
        host.zamaHost.execute -> host.zamaHost.events "Emits FheExecutedEvent through"
        host.zamaHost.execute -> host.zamaHost.stores "Writes slots and appends MMR leaves to"
        host.zamaHost.publicDecrypt -> host.zamaHost.kmsContexts "Checks certificates against"
        host.zamaHost.stores -> host.shared.acl "Layout, seeds and MMR from"
        host.zamaHost.userDecrypt -> host.shared.acl "Delegation layout from"

        # Client SDKs
        host.jsSdk.sdkClients -> host.jsSdk.encrypt "Exposes"
        host.jsSdk.sdkClients -> host.jsSdk.sdkUserDecrypt "Exposes"
        host.jsSdk.sdkClients -> host.jsSdk.sdkPublicDecrypt "Exposes"
        host.jsSdk.sdkUserDecrypt -> host.jsSdk.permits "Signs requests with"
        host.jsSdk.sdkUserDecrypt -> host.jsSdk.transport "Sends through"
        # I: decryption/relayerHttp.ts builds its URL per operation, so public decryption is assumed to use it too.
        host.jsSdk.sdkPublicDecrypt -> host.jsSdk.transport "Sends through"
        host.jsSdk.sdkPublicDecrypt -> host.hostClient "Submits verify_public_decrypt with"
        host.jsSdk.hostActions -> host.hostClient "Builds and sends instructions with"
        host.jsSdk.encrypt -> relayer.inputRelay "Submits input proofs to" "HTTPS"
        host.jsSdk.transport -> relayerHttp.router "Posts decryption requests to" "HTTPS"
        host.hostClient -> cluster "Sends version-1 transactions and reads accounts at finalized" "JSON-RPC"
        host.tokenClient -> cluster "Sends confidential-token instructions to" "JSON-RPC"

        # Solana programs run on the cluster
        cluster -> host.zamaHost "Executes"
        cluster -> host.token "Executes"

        # Input attestation path
        relayer.inputRelay -> gateway.inputVerification "Calls verifyProofRequestSolana"
        coprocessor.attestation -> gateway.inputVerification "Reads requests and submits signed responses"

        # Coprocessor follows the host
        coprocessor.listener -> cluster "Follows zama-host at finalized" "Yellowstone gRPC, JSON-RPC"
        coprocessor.listener -> host.shared.transaction "Resolves compiled instructions with"
        coprocessor.listener -> host.shared.acl "Uses chain-id rules from"
        coprocessor.listener -> coprocessor.workers "Schedules FHE compute for"
        coprocessor.merkleService -> cluster "Indexes zama-host at finalized" "Yellowstone gRPC, JSON-RPC"
        coprocessor.merkleService -> host.shared.acl "Rebuilds MMR leaves with"
        coprocessor.merkleService -> host.shared.merkleProofs "Serves proofs in the format of"
        coprocessor.attestation -> host.shared.acl "Uses chain-id rules from"

        # Decryption path
        relayerHttp.router -> kmsConnector.endpoint "Forwards decryption requests to" "HTTPS"
        relayerHttp.router -> host.shared.request "Checks request form with"
        relayerHttp.router -> host.shared.permit "Decodes permits with"
        kmsConnector.endpoint -> kmsConnector.kmsWorker "Queues requests for"
        kmsConnector.endpoint -> host.shared.request "Checks request form with"
        kmsConnector.kmsWorker -> host.shared.permit "Verifies permits with"
        kmsConnector.kmsWorker -> host.shared.acl "Authorizes decryption with"
        kmsConnector.kmsWorker -> cluster "Reads encrypted stores and delegations at finalized" "JSON-RPC"
        kmsConnector.kmsWorker -> coprocessor.merkleService "Fetches MMR inclusion proofs from" "HTTP, CBOR"
        kmsConnector.kmsWorker -> kmsCore "Requests threshold decryption from"
    }

    views {

        systemLandscape "L1-Landscape" "Level 1: the Solana host among Zama's systems. Green is in review scope." {
            include *
            autoLayout tb
        }

        container host "L2-Host" "Level 2: what the FHEVM Solana host is made of." {
            include *
            autoLayout tb
        }

        container kmsConnector "L2-Seams" "Level 2: the Solana-facing parts of the off-chain services (amber) and what they touch in scope." {
            include host.zamaHost host.shared host.jsSdk cluster
            include element.tag==Seam
            autoLayout tb
        }

        component host.zamaHost "L3-zama-host" "Level 3: zama-host instruction families." {
            include *
            autoLayout tb
        }

        component host.shared "L3-Shared-crates" "Level 3: the shared crates and who compiles them in." {
            include *
            autoLayout tb
        }

        component host.jsSdk "L3-js-sdk" "Level 3: the Solana client SDK." {
            include *
            autoLayout tb
        }

        /*
         * Flow views. Each one is a dynamic view, so Structurizr can draw it as a sequence diagram.
         *
         * Shielding: one transaction [open_transient_store, initialize_token_account, wrap_usdc,
         * close_transient_store], as the demo-dapp composes it (demo-dapp/src/deposit.ts L337-L359).
         * - The sandwich and its order: sdk/js-sdk/src/solana/transientStore.ts L78-L90.
         * - Sending at finalized: demo-dapp/src/demoClient.ts L19-L23 (finalizedTransactionSending
         *   from @fhevm/solana-zama-host, transientStoreTransactions from @fhevm/sdk/solana).
         * - initialize_token_account returns early when the account exists:
         *   programs/confidential-token/src/instructions/initialize_token_account.rs L42-L44.
         * - wrap_usdc: programs/confidential-token/src/instructions/wrap_usdc.rs L106-L187.
         * - fhe_execute requires an open transient store and a final close:
         *   programs/zama-host/src/instructions/fhe_execute.rs L104-L112.
         * - The off-chain steps start at finalized. They are asynchronous and not part of the transaction.
         */
        dynamic host "F1-Shielding" "Flow: shield public USDC into a confidential balance, in one transaction." {
            user -> host.tokenClient "Builds initialize_token_account (no-op if the account exists) and wrap_usdc(amount)"
            user -> host.jsSdk "prepareTransientStore, then signFheTransaction(instructions)"
            host.jsSdk -> host.hostClient "Wraps the instructions in open_transient_store ... close_transient_store"
            host.hostClient -> cluster "Sends the transaction and confirms it at finalized"
            cluster -> host.zamaHost "open_transient_store"
            cluster -> host.token "initialize_token_account"
            host.token -> host.zamaHost "create_encrypted_store for the balance, by CPI"
            host.token -> host.zamaFhe "Builds trivial_encrypt(0) into the balance slot"
            host.zamaFhe -> host.zamaHost "fhe_execute by CPI"
            cluster -> host.token "wrap_usdc(amount)"
            host.token -> splToken "transfer_checked: owner's ATA to the vault ATA"
            host.token -> host.zamaFhe "Builds trivial_encrypt(amount) and a clamped add to the balance and the total supply"
            host.zamaFhe -> host.zamaHost "fhe_execute by CPI: writes both slots, appends MMR leaves, emits FheExecutedEvent"
            cluster -> host.zamaHost "close_transient_store (must be last)"
            {
                {
                    coprocessor.listener -> cluster "Reads the finalized block and rebuilds both executions"
                    coprocessor.listener -> coprocessor.workers "Schedules the FHE operations"
                }
                {
                    coprocessor.merkleService -> cluster "Indexes the new balance and total-supply leaves"
                }
            }
            autoLayout lr
            properties {
                "mermaid.sequenceDiagram" "true"
            }
        }

        styles {
            element "Element" {
                color #ffffff
                stroke #444444
            }
            element "Person" {
                shape Person
            }
            element "Program" {
                shape Hexagon
            }
            element "Library" {
                shape Folder
            }
            element "Database" {
                shape Cylinder
            }
            element "Solana" {
                background #1b7f5f
                color #ffffff
                stroke #0f4d39
            }
            element "Seam" {
                background #f2b134
                color #222222
                stroke #8a5d00
                border dashed
            }
            element "Out of scope" {
                background #c8c8c8
                color #333333
                stroke #888888
                border dashed
            }
            relationship "Relationship" {
                color #666666
            }
        }
    }
}
