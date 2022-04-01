// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YusufToken is ERC20 {
    enum VoteStatus {
        ACTIVE,
        ACCEPTED,
        REJECTED
    }
    uint256 private constant REJECT = 0;
    uint256 private constant ACCEPT = 1;
    uint256 private constant DAY = 86400;
    string private constant SUSPENDEDMESSAGE = "SAME VOTE FOR ACCEPT AND REJECT PROPOSAL SUSPENDED";
    error invalidVoteAsParam(uint256 voteAs, string message);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10000000 * 10**uint256(decimals()));
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    modifier openProposal(uint256 proposalId) {
        require(
            block.timestamp <
                (proposals[proposalId].createdTime + (proposals[proposalId].deadlineAsDays) * DAY),
            "PROPOSAL CLOSED TO VOTE"
        );
        _;
    }

    modifier closedProposal(uint256 proposalId) {
        require(
            block.timestamp >
                (proposals[proposalId].createdTime + (proposals[proposalId].deadlineAsDays) * DAY),
            "VOTE IS STILL ACTIVE"
        );
        _;
    }

    modifier validProposalId(uint256 proposalId) {
        require(proposals.length > 0 && proposalId < proposals.length, "PROPOSAL NOT FOUND");
        _;
    }

    struct Proposal {
        address creator;
        string name;
        string description;
        uint256 acceptedVotes;
        uint256 rejectedVotes;
        VoteStatus status;
        uint256 createdTime;
        uint256 deadlineAsDays;
    }

    Proposal[] public proposals;

    // callData isread only so its safer to use for this function
    function addProposal(
        string calldata name,
        string calldata description,
        uint256 deadlineAsDays
    ) external {
        require(deadlineAsDays > 0, "PROPOSAL MUST LAST AT LEAST 1 DAY");
        proposals.push(
            Proposal(
                msg.sender,
                name,
                description,
                0,
                0,
                VoteStatus.ACTIVE,
                block.timestamp,
                deadlineAsDays
            )
        );
    }

    function voteProposal(
        uint256 voteAs,
        uint256 amount,
        uint256 proposalId
    ) external validProposalId(proposalId) openProposal(proposalId) {
        require(proposals[proposalId].status == VoteStatus.ACTIVE, "Invalid proposalStatus");
        require(balanceOf(msg.sender) > amount, "Unsufficient Balance");

        if (voteAs == REJECT) {
            proposals[proposalId].rejectedVotes += amount;
            _burn(msg.sender, amount);
        } else if (voteAs == ACCEPT) {
            proposals[proposalId].acceptedVotes += amount;
            _burn(msg.sender, amount);
        } else {
            revert invalidVoteAsParam(voteAs, "INVALID PARAM MUST BE 0 FOR REJECT , 1 FOR ACCEPT ");
        }
    }

    function finalizeProposal(uint256 proposalId) internal closedProposal(proposalId) {
        require(
            proposals[proposalId].status == VoteStatus.ACTIVE,
            "Cant finalize finalized Proposal"
        );

        if (proposals[proposalId].acceptedVotes > proposals[proposalId].rejectedVotes) {
            proposals[proposalId].status = VoteStatus.ACCEPTED;
        } else if (proposals[proposalId].acceptedVotes < proposals[proposalId].rejectedVotes) {
            proposals[proposalId].status = VoteStatus.REJECTED;
        } else {
            revert(SUSPENDEDMESSAGE);
        }
    }

    function isProposalAccepted(uint256 proposalId) external returns (bool) {
        if (
            block.timestamp >
            (proposals[proposalId].createdTime + (proposals[proposalId].deadlineAsDays) * DAY)
        ) {
            if (proposals[proposalId].status == VoteStatus.ACTIVE) {
                finalizeProposal(proposalId);
            }
        }
        if (proposals[proposalId].status == VoteStatus.ACCEPTED) {
            return true;
        } else {
            return false;
        }
    }
}
