pragma solidity ^0.5.0;

import "./base/Cancelable.sol";
import "./base/DelegatecallExecutableProposal.sol";

/**
 * @dev NetworkParameter proposal
 */
contract NetworkParameterProposal is DelegatecallExecutableProposal, Cancelable {
    address public sfc;
    string public parameterFunction;
    uint256[] public optionsList;

    constructor(string memory __name, string memory __description, bytes32[] memory __options, 
        uint256 __minVotes, uint256 __minAgreement, uint256 __start, uint256 __minEnd, uint256 __maxEnd,
        address _sfc, address verifier, string memory _parameterFunction, uint256[] memory _optionsList) public {
        _name = __name;
        _description = __description;
        _options = __options;
        _minVotes = __minVotes;
        _minAgreement = __minAgreement;
        _opinionScales = [0, 1, 2, 3, 4];
        _start = __start;
        _minEnd = __minEnd;
        _maxEnd = __maxEnd;
        sfc = _sfc;
        parameterFunction = _parameterFunction;
        optionsList = _optionsList;
        // verify the proposal right away to avoid deploying a wrong proposal
        if (verifier != address(0)) {
            require(verifyProposalParams(verifier), "failed verification");
        }
    }

    event NetworkParameterUpgradeIsDone(uint256 winnerOption);

    function execute_delegatecall(address selfAddr, uint256 winnerOption) external {
        NetworkParameterProposal self = NetworkParameterProposal(selfAddr);

        self.sfc().call(abi.encodeWithSignature(self.parameterFunction(), self.optionsList(winnerOption)));
        emit NetworkParameterUpgradeIsDone(winnerOption);
    }
}