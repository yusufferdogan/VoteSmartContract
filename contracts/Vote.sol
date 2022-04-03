// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YusufToken is ERC20 {
    uint256 private constant REJECT = 0;
    uint256 private constant ACCEPT = 1;
    uint256 private constant DAY = 86400;
    string private constant SUSPENDED_MESSAGE = "SAME VOTE FOR ACCEPT AND REJECT PROPOSAL SUSPENDED";
    error invalidVoteAsParam(uint256 voteAs, string message);

    constructor(/*string memory name, string memory symbol*/) ERC20("YusufToken", "Yusuf") {
        _mint(msg.sender, 100000 * 10**uint256(decimals()));
    }

    function faucet(uint256 amount) external {
        _mint(msg.sender, amount * 10**uint256(decimals()));
    } 

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    modifier openProposal(uint256 proposalId) {
        require(
            block.timestamp <
                (proposals[proposalId].deadline),
            "PROPOSAL CLOSED TO VOTE"
        );
        _;
    }

    modifier closedProposal(uint256 proposalId) {
        require(
            block.timestamp >
                (proposals[proposalId].deadline),
            "PROPOSAL IS OPEN TO VOTE"
        );
        _;
    }

    modifier validProposalId(uint256 proposalId) {
        require(proposals[proposalId].creator != address(0), "PROPOSAL NOT FOUND");
        _;
    }

    struct Proposal {
        address creator;
        string name;
        string description;
        uint256 acceptedVotes;
        uint256 rejectedVotes;
        uint256 deadline;
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
                block.timestamp + deadlineAsDays * DAY
            )
        );
    }

    function voteProposal(
        uint256 voteAs,
        uint256 amount,
        uint256 proposalId
    ) external validProposalId(proposalId) openProposal(proposalId) {
        require(balanceOf(msg.sender) > amount, "Unsufficient Balance");
        if(voteAs != REJECT && voteAs != ACCEPT) {
            revert invalidVoteAsParam(voteAs, "INVALID PARAM MUST BE 0 FOR REJECT , 1 FOR ACCEPT ");
        }
        if (voteAs == REJECT) {
            proposals[proposalId].rejectedVotes += amount;
        } else if (voteAs == ACCEPT) {
            proposals[proposalId].acceptedVotes += amount;
        } 
        _burn(msg.sender, amount);
    }

    function isProposalAccepted(uint256 proposalId) external view closedProposal(proposalId) returns (bool) {
        if (proposals[proposalId].acceptedVotes > proposals[proposalId].rejectedVotes) {
            return true;
        } else if (proposals[proposalId].acceptedVotes < proposals[proposalId].rejectedVotes) {
            return false;
        } else {
            revert(SUSPENDED_MESSAGE);
        }
    }
}
