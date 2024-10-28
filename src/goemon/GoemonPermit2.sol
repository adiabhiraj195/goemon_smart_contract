// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../interfaces/ISignatureTransfer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GoemonPermit2 {
    ISignatureTransfer public immutable permit2;

    constructor(address permit2Address) {
        // Initialize Permit2 contract instance
        permit2 = ISignatureTransfer(permit2Address);
    }

    event PermitTransfer(
        address indexed token,
        address indexed owner,
        address indexed receiver,
        uint256 amount
    );

    // /**
    //  * @notice Transfers tokens using Uniswap's Permit2 system.
    //  * @param token Address of the ERC20 token being transferred
    //  * @param owner Address of the token owner
    //  * @param receiver Address of the token recipient
    //  * @param amount Amount of tokens to transfer
    //  * @param nonce Nonce for the permit signature
    //  * @param deadline Time by which the permit must be used
    //  * @param sig The signed data (permit) authorizing the transfer
    //  */

    // function transferWithPermit(
    //     address token,
    //     uint256 amount,
    //     uint256 nonce,
    //     uint256 deadline,
    //     bytes calldata sig
    // ) external {
    //     uint256 balance = IERC20(token).balanceOf(msg.sender);
    //     require(balance >= amount, "Insufficient token balance");
    //     require(amount > 0, "Amount must be greater than zero");

    //     // Define the permit data structure
    //     ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer
    //         .PermitTransferFrom({
    //             permitted: ISignatureTransfer.TokenPermissions({
    //                 token: token,
    //                 amount: amount
    //             }),
    //             nonce: nonce,
    //             deadline: deadline
    //         });

    //     // Define the transfer request
    //     ISignatureTransfer.SignatureTransferDetails
    //         memory transferDetails = ISignatureTransfer
    //             .SignatureTransferDetails({
    //                 to: address(this),
    //                 requestedAmount: amount
    //             });

    //     // Execute the permit transfer
    //     permit2.permitTransferFrom(permit, transferDetails, msg.sender, sig);
    //     emit PermitTransfer(token, msg.sender, address(this), amount);
    // }

    function transferWithPermit(
        address token,
        address receiver,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata sig
    ) external {
        require(amount > 0, "Amount must be greater than zero");
        uint256 balance = IERC20(token).balanceOf(msg.sender);
        require(balance >= amount, "Insufficient token balance");
        // Define the permit data structure
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer
            .PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: token,
                    amount: amount
                }),
                nonce: nonce,
                deadline: deadline
            });

        // Define the transfer request
        ISignatureTransfer.SignatureTransferDetails
            memory transferDetails = ISignatureTransfer
                .SignatureTransferDetails({
                    to: receiver,
                    requestedAmount: amount
                });

        // Execute the permit transfer
        permit2.permitTransferFrom(permit, transferDetails, msg.sender, sig);
        emit PermitTransfer(token, msg.sender, receiver, amount);
    }

    /**
     * @notice Helper function to check balances after transfer
     * @param token Address of the ERC20 token
     * @param account Address to check balance for
     * @return balance Token balance of the account
     */
    function getBalance(
        address token,
        address account
    ) public view returns (uint256 balance) {
        return IERC20(token).balanceOf(account);
    }
}
