/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

 const HDWalletProvider = require('@truffle/hdwallet-provider');

 const fs = require('fs');
 const mnemonic = fs.readFileSync(".secret").toString().trim();
 
 require("dotenv").config();
 
 module.exports = {
   /**
    * Networks define how you connect to your ethereum client and let you set the
    * defaults web3 uses to send transactions. If you don't specify one truffle
    * will spin up a development blockchain for you on port 9545 when you
    * run `develop` or `test`. You can ask a truffle command to use a specific
    * network from the command line, e.g
    *
    * $ truffle test --network <network-name>
    */
 
   networks: {
     development: {
       host: "127.0.0.1",     // Localhost (default: none)
       port: 8545,            // Standard Ethereum port (default: none)
       network_id: "*",       // Any network (default: none)
       gasPrice: 60
     },
 
     ropsten: {
       provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${process.env.INFURA}`),
       network_id: 3,       // Ropsten's id
       gas: 5500000,        // Ropsten has a lower block limit than mainnet
       confirmations: 2,    // # of confs to wait between deployments. (default: 0)
       timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
       skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
     },
 
     rinkeby: {
       provider: () => new HDWalletProvider(mnemonic, `wss://rinkeby.infura.io/ws/v3/${process.env.INFURA}`),
       network_id: 4,
       timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
       skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
     },
 
     ht: {
       provider: () => new HDWalletProvider(mnemonic, `wss://ws.s0.pops.one/`),
       network_id: 1666700000,       // Testnet's id
     },
 
     hm: {
       provider: () => new HDWalletProvider(mnemonic, `https://api.s0.t.hmny.io/`),
       network_id: 1666600000,       // Mainnet's id
     },
 
     at: {
       provider: () => new HDWalletProvider(mnemonic, `https://testnet.aurora.dev`),
       network_id: 0x4e454153,       // Testnet's id
       gas: 10000000,       
     },
 
     am: {
       provider: () => new HDWalletProvider(mnemonic, `https://mainnet.aurora.dev`),
       network_id: 0x4e454152,       // Mainnet's id
       gas: 10000000,
     },
   },
 
   // Set default mocha options here, use special reporters etc.
   mocha: {
     // timeout: 100000
   },
 
   // Configure your compilers
   compilers: {
     solc: {
       version: "^0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
       // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
       // settings: {          // See the solidity docs for advice about optimization and evmVersion
       //  optimizer: {
       //    enabled: false,
       //    runs: 200
       //  },
       //  evmVersion: "byzantium"
       // }
     }
   },
 
   // Truffle DB is currently disabled by default; to enable it, change enabled:
   // false to enabled: true. The default storage location can also be
   // overridden by specifying the adapter settings, as shown in the commented code below.
   //
   // NOTE: It is not possible to migrate your contracts to truffle DB and you should
   // make a backup of your artifacts to a safe location before enabling this feature.
   //
   // After you backed up your artifacts you can utilize db by running migrate as follows: 
   // $ truffle migrate --reset --compile-all
   //
   // db: {
     // enabled: false,
     // host: "127.0.0.1",
     // adapter: {
     //   name: "sqlite",
     //   settings: {
     //     directory: ".db"
     //   }
     // }
   // }
 };
 