pragma solidity ^0.5.0;

import "./base/Cancelable.sol";
import "./base/DelegatecallExecutableProposal.sol";
import "hardhat/console.sol";

interface SFC {
    function setMaxDelegation(uint256) external;
}

/**
 * @dev NetworkParameter proposal
 */
contract NetworkParameterProposal is DelegatecallExecutableProposal, Cancelable {
    Proposal.ExecType _exec;
    address public sfcAddress;

    constructor(string memory __name, string memory __description, bytes32[] memory __options, 
        uint256 __minVotes, uint256 __minAgreement, uint256 __start, uint256 __minEnd, uint256 __maxEnd,
        address _sfc, address verifier) public {
        _name = __name;
        _description = __description;
        _options = __options;
        _minVotes = __minVotes;
        _minAgreement = __minAgreement;
        _opinionScales = [0, 1, 2, 3, 4];
        _start = __start;
        _minEnd = __minEnd;
        _maxEnd = __maxEnd;
        sfcAddress = _sfc;
        // verify the proposal right away to avoid deploying a wrong proposal
        if (verifier != address(0)) {
            require(verifyProposalParams(verifier), "failed verification");
        }
    }

    function setOpinionScales(uint256[] memory v) public {
        _opinionScales = v;
    }

    function pType() public view returns (uint256) {
        return 15;
    }

    function executable() public view returns (Proposal.ExecType) {
        return _exec;
    }

    function setExecutable(Proposal.ExecType __exec) public {
        _exec = __exec;
    }

    function cancel(uint256 myID, address govAddress) public {
        Governance gov = Governance(govAddress);
        gov.cancelProposal(myID);
    }

    uint256 public executedCounter;
    address public executedMsgSender;
    address public executedAs;
    uint256 public executedOption;

    function executeNonDelegateCall(address _executedAs, address _executedMsgSender, uint256 optionID) public {
        executedAs = _executedAs;
        executedMsgSender = _executedMsgSender;
        executedCounter += 1;
        executedOption = optionID;
    }

    function execute_delegatecall(address selfAddr, uint256 optionID) external {
        console.log("NetworkParameterProposal: execute_delegatecall");
        NetworkParameterProposal self = NetworkParameterProposal(selfAddr);
        SFC sfc = SFC(self.sfcAddress());
        sfc.setMaxDelegation(15);
        self.executeNonDelegateCall(address(this), msg.sender, optionID);
    }
}