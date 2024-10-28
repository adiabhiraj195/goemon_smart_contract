// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../interfaces/ISignatureTransfer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Goemon {
    struct Intent {
        address token;
        address recipient;
        uint256 amount;
        uint256 frequency; // E.g., 1 month (in seconds)
        uint256 nextExecution;
    }

    ISignatureTransfer public immutable permit2;
    uint256 private s_countIntents = 0;

    mapping(address => mapping(uint256 => Intent)) public userIntents;

    constructor(address permit2Address) {
        // Initialize Permit2 contract instance
        permit2 = ISignatureTransfer(permit2Address);
    }

    event PermitTransfer(address indexed token, address indexed owner, address indexed receiver, uint256 amount);
    event IntentCreated(
        address indexed user, uint256 indexed intentIndex, address indexed recipient, uint256 amount, uint256 frequency
    );
    event IntentExecuted(address indexed user, uint256 intentIndex);
    event IntentCanceled(address indexed user, uint256 intentIndex);

    ////////////////////  intent  ////////////////////////
    // create new intent
    function createIntent(address _token, address _recipient, uint256 _amount, uint256 _frequency) external {
        require(_token != address(0), "Invalid token address");
        require(_recipient != address(0), "Invalid recipient address");
        require(_amount > 0, "Amount must be greater than 0");
        require(_frequency > 0, "Frequency must be greater than 0");

        Intent memory newIntent = Intent({
            token: _token,
            recipient: _recipient,
            amount: _amount,
            frequency: _frequency,
            nextExecution: block.timestamp + _frequency
        });
        s_countIntents += 1;
        userIntents[msg.sender][s_countIntents] = newIntent;

        emit IntentCreated(msg.sender, s_countIntents, _recipient, _amount, _frequency);
    }
    //  modifier onlyOwner(uint256 index) {
    //     Intent memory intent = userIntents[msg.sender][index];
    //     require(intent, "Not owner");
    //     _;
    // }

    function executeIntent(address _user, uint256 _intentIndex) external payable {
        require(_intentIndex <= s_countIntents, "Invalid intent index");
        Intent storage intent = userIntents[_user][_intentIndex];
        require(block.timestamp >= intent.nextExecution, "Execution too early");
        require(msg.value == intent.amount, "Send Wrong amount");

        (bool success,) = intent.recipient.call{value: msg.value}("");
        require(success, "tx failed");

        emit IntentExecuted(_user, _intentIndex);
    }

    // execute intent with permit
    function executeIntentWithPermit(
        address _user,
        uint256 _intentIndex,
        uint256 _nonce,
        uint256 _deadline,
        bytes calldata _signature
    ) public {
        require(_intentIndex <= s_countIntents, "Invalid intent index");

        Intent storage intent = userIntents[_user][_intentIndex];
        require(block.timestamp >= intent.nextExecution, "Execution too early");

        transferWithPermit(intent.token, intent.recipient, intent.amount, _nonce, _deadline, _signature);

        intent.nextExecution += intent.frequency;
        emit IntentExecuted(_user, _intentIndex);
    }

    // check for condition and execute intent
    function checkAndExecute(
        address _user,
        uint256 _intentIndex,
        uint256 _nonce,
        uint256 _deadline,
        bytes calldata _signature
    ) external {
        if (block.timestamp >= userIntents[_user][_intentIndex].nextExecution) {
            executeIntentWithPermit(_user, _intentIndex, _nonce, _deadline, _signature);
        }
    }

    //delete inetent
    function cancelIntent(uint256 _intentIndex) external {
        require(_intentIndex <= s_countIntents, "Invalid intent index");

        delete (userIntents[msg.sender][_intentIndex]);
        emit IntentCanceled(msg.sender, _intentIndex);
    }

    // permit2 transfer
    function transferWithPermit(
        address token,
        address receiver,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata sig
    ) public {
        require(amount > 0, "Amount must be greater than zero");
        uint256 balance = IERC20(token).balanceOf(msg.sender);
        require(balance >= amount, "Insufficient token balance");
        // Define the permit data structure
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({token: token, amount: amount}),
            nonce: nonce,
            deadline: deadline
        });

        // Define the transfer request
        ISignatureTransfer.SignatureTransferDetails memory transferDetails =
            ISignatureTransfer.SignatureTransferDetails({to: receiver, requestedAmount: amount});

        // Execute the permit transfer
        permit2.permitTransferFrom(permit, transferDetails, msg.sender, sig);
        emit PermitTransfer(token, msg.sender, receiver, amount);
    }
}
