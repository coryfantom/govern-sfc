pragma solidity ^0.5.0;

import "./base/Cancelable.sol";
import "./base/DelegatecallExecutableProposal.sol";

/**
 * @dev DynamicNetworkProposal proposal
 */
contract DynamicNetworkProposal is DelegatecallExecutableProposal, Cancelable {
    Proposal.ExecType _exec;
    address public sfcAddress;
    string public signature;
    uint256[] public optionsList;

    constructor(string memory __name, string memory __description, bytes32[] memory __options, 
        uint256 __minVotes, uint256 __minAgreement, uint256 __start, uint256 __minEnd, uint256 __maxEnd,
        address __sfc, address verifier, string memory __signature, uint256[] memory __optionList, Proposal.ExecType __exec, uint256[] memory __scales) public {
        _name = __name;
        _description = __description;
        _options = __options;
        _minVotes = __minVotes;
        _minAgreement = __minAgreement;
        _opinionScales = __scales;
        _start = __start;
        _minEnd = __minEnd;
        _maxEnd = __maxEnd;
        sfcAddress = __sfc;
        signature = __signature;
        optionsList = __optionList;
        _exec = __exec;
        // verify the proposal right away to avoid deploying a wrong proposal
        if (verifier != address(0)) {
            require(verifyProposalParams(verifier), "failed verification");
        }
    }

    function pType() public view returns (uint256) {
        return 15;
    }

    function executable() public view returns (Proposal.ExecType) {
        return _exec;
    }

    event NetworkParameterUpgradeIsDone(uint256 newValue);

    function execute_delegatecall(address selfAddr, uint256 winnerOptionID) external {
        DynamicNetworkProposal self = DynamicNetworkProposal(selfAddr);
        self.sfcAddress().call(abi.encodeWithSignature(self.signature(), self.optionsList(winnerOptionID)));
        emit NetworkParameterUpgradeIsDone(self.optionsList(winnerOptionID));
    }
}