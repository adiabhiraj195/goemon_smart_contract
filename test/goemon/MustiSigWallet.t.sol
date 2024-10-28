// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../src/goemon/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    address owner1 = address(0x3433);
    address owner2 = address(0x3423);
    address owner3 = address(0x4239);

    function setUp() public {
        address[] memory owners;
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSigWallet(owners, 2);
    }

    function testSubmitTransaction() public {
        vm.startPrank(owner1);
        wallet.submitTransaction(address(0xABC), 1 ether, "");
        (address to, uint256 value,,, uint256 confirmations) = wallet.transactions(0);
        assertEq(to, address(0xABC));
        assertEq(value, 1 ether);
        assertEq(confirmations, 0);
        vm.stopPrank();
    }

    function testConfirmTransaction() public {
        vm.startPrank(owner1);
        wallet.submitTransaction(address(0xABC), 1 ether, "");
        vm.stopPrank();

        vm.startPrank(owner2);
        wallet.confirmTransaction(0);
        (,,,, uint256 confirmations) = wallet.transactions(0);
        assertEq(confirmations, 1);
        vm.stopPrank();
    }

    function testExecuteTransaction() public {
        vm.deal(address(wallet), 1 ether);

        vm.startPrank(owner1);
        wallet.submitTransaction(address(0xABC), 1 ether, "");
        vm.stopPrank();

        vm.startPrank(owner2);
        wallet.confirmTransaction(0);
        (,,, bool executed,) = wallet.transactions(0);
        assertTrue(executed);
        vm.stopPrank();
    }

    function testRevokeConfirmation() public {
        vm.startPrank(owner1);
        wallet.submitTransaction(address(0xABC), 1 ether, "");
        wallet.confirmTransaction(0);

        (,,,, uint256 confirmations) = wallet.transactions(0);
        assertEq(confirmations, 0);
        vm.stopPrank();
    }
}
