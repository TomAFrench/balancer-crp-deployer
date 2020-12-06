// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;
pragma abicoder v2;

import "hardhat/console.sol";

import {BFactory, BPool, ConfigurableRightsPool, CRPFactory, ERC20, RightsManager} from "./BalancerContracts.sol";

contract BalancerPoolDeployer {

    function create(
        BFactory factory,
        address[] calldata tokens,
        uint[] calldata balances,
        uint[] calldata weights,
        uint swapFee,
        bool finalize
    ) external returns (BPool pool) {
        require(tokens.length == balances.length, "ERR_LENGTH_MISMATCH");
        require(tokens.length == weights.length, "ERR_LENGTH_MISMATCH");

        pool = factory.newBPool();
        pool.setSwapFee(swapFee);

        // Pull in initial balances of tokens and bind them to pool
        for (uint i = 0; i < tokens.length; i++) {
            ERC20 token = ERC20(tokens[i]);
            require(token.transferFrom(msg.sender, address(this), balances[i]), "ERR_TRANSFER_FAILED");
            token.approve(address(pool), balances[i]);
            pool.bind(tokens[i], balances[i], weights[i]);
        }

        // If public (finalized) pool then send BPT tokens to msg.sender
        if (finalize) {
            pool.finalize();
            require(pool.transfer(msg.sender, pool.balanceOf(address(this))), "ERR_TRANSFER_FAILED");
        } else {
            pool.setPublicSwap(true);
        }

        // Set msg.sender to be controller of newly created pool
        pool.setController(msg.sender);
    }
    
    function createSmartPool(
        CRPFactory factory,
        BFactory bFactory,
        ConfigurableRightsPool.PoolParams calldata poolParams,
        ConfigurableRightsPool.CrpParams calldata crpParams,
        RightsManager.Rights calldata rights
    ) external returns (ConfigurableRightsPool crp) {
        require(
            poolParams.constituentTokens.length == poolParams.tokenBalances.length,
            "ERR_LENGTH_MISMATCH"
        );
        require(
            poolParams.constituentTokens.length == poolParams.tokenWeights.length,
            "ERR_LENGTH_MISMATCH"
        );

        // Deploy the CRP controller contract
        crp = factory.newCrp(
            address(bFactory),
            poolParams,
            rights
        );
        
        // Pull in initial balances of tokens for CRP
        for (uint i = 0; i < poolParams.constituentTokens.length; i++) {
            ERC20 token = ERC20(poolParams.constituentTokens[i]);
            require(
                token.transferFrom(msg.sender, address(this), poolParams.tokenBalances[i]),
                "ERR_TRANSFER_FAILED"
            );
            token.approve(address(crp), poolParams.tokenBalances[i]);
        }
        
        // Deploy the underlying BPool
        crp.createPool(
            crpParams.initialSupply,
            crpParams.minimumWeightChangeBlockPeriod,
            crpParams.addTokenTimeLockInBlocks
        );

        // Return BPT to msg.sender
        require(crp.transfer(msg.sender, crpParams.initialSupply), "ERR_TRANSFER_FAILED");

        // Set msg.sender to be controller of newly created pool
        crp.setController(msg.sender);
    }
}
