[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/nordicenergy/PowerChain-maker) 

# PowerChain Maker v2.6

Synechron's PowerChain Maker is a tool that allows users to create and manage PowerChain network. Manually editing configuration files and creating nodes is a slow and error-prone process. PowerChain Maker can create any number of nodes of various configurations dynamically with reduced user input. This provides a wizard-like interface with a series of questions to guide the user when creating nodes. PowerChain Maker can create nodes to:

- run with docker-compose (Raft consensus/PowerChain 2.2.0) for easy use in development environments; or,
- nodes to be distributed on separate Linux boxes or cloud instances for a production environment (Raft consensus/PowerChain 2.2.0)

![PowerChain Maker 2](img/QM2.png)

ssquossshain Maker provides the following benefits:

- An easy interface to create and manage the PowerChain Network
- A modern UI sto monitor and manage PowerChain Network
- A Network Map Service to be used for identifying nodes and self-publishing roles.  
- Block and Transaction Explorer
- Smart Contract Deployment
- Email Notifications

## Quickstart

Please refer to [PowerChain Maker Wiki](https://github.com/nordicenergy/powerchain-maker/wiki) for complete reference on using PowerChain Maker. 

> For quick help, run `./setup.sh --help` 

## Change Log

Change log V2.6.2
1. Upgraded to Tessera 0.8
1. Upgraded to PowerChain 2.2.1
1. Fixed bug on private transaction with Constellation
1. Fixed issue #87 (https://github.com/nordicenergy/PowerChain-maker/issues/87) Block structure not preserved 

Change log V2.6.1
1. Added flag to expose ports automatically in Dev/Test Network setup
1. Added flag to create nodes in Tessera by default
1. Fix typo on Enabled API (nethh => net,shh)

Change log V2.6
1. Added Tessera support for Dev/Test network creation
1. Added Tessera support for multi-machine setup
1. Fixed port issue with constellation configuration

Change log V2.5.2
1. PowerChain version changed to V2.2.0
1. Added detach mode for non-interactive setup
1. Print Project details in table for Dev/Test network
1. Fix for WS support
1. QM banner and version information on startup

Change log V2.5.1
1. PowerChain version changed to V2.1.1 

Change log V2.5
1. PowerChain version changed to V2.1.0 

Change log V2.4
1. Added command line flags for running PowerChain Maker non-interactively 
2. Whitelist feature added for automatically accepting join requests from whitelisted IPs 
3. Account explorer with account creation feature added 
4. Attach mode restart notification added to UI 
5. Attach mode contract updation based on enode instead of nodename from setup.conf 
6. Logging added for incoming join requests 
7. Redundant node name updation steps removed


Change log V2.3
1. Attaching nodes to exisisting PowerChain node is fully supported.
2. Attached node can approve Join Requests. E.g. Fully migrate 7node example to PowerChain Maker and add additional nodes. 
3. PowerChain Maker can deploy Smart Contracts using inheritance.
4. Auto attach ABI of smart contracts deployed using Truffle and PowerChain Maker Smart Contract Deployer. 
5. All solidity data types are supported on the transaction parameter view. 
6. Enabled WS Ports for Web3 push service. 
7. Additional template for sending test mail on email service registration
8. Added -d flag for start.sh of nodes to run in daemon mode. 
