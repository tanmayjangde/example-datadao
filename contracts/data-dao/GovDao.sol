// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GovDao{

    struct RoyaltyPercentageProposal {
        uint id;
        string description;
        uint votes;
        uint percentageProposed;
        bool executed;
    }

    struct MusicCostProposal{
        uint id;
        string descrpition;
        uint votes;
        uint cost;
        bool executed;
    }

    //IERC20 public artistToken;
    IERC20 public musicToken;
    //IERC20 public governanceToken;
    uint private royaltyPercentageArtist;
    uint private musicCost;

    mapping (uint => RoyaltyPercentageProposal) public royaltyProposals;
    mapping (uint => MusicCostProposal) public musicCostProposals;
    mapping (address => bool) public members;
    mapping (uint => mapping (address => bool)) hasVotedRoyaltyPercentage;
    mapping (uint => mapping (address => bool)) hasVotedMusicCost;
    uint public numberOfMembers;
    uint public numRoyaltyProposals;
    uint public numMusicCostProposals;

    constructor(address _musicTokenAddress, uint _royaltyPercentage, uint _musicCost) {
        //artistToken = IERC20(_artistTokenAddress);
        musicToken = IERC20(_musicTokenAddress);
        //governanceToken = IERC20(_governanceToken);
        royaltyPercentageArtist = _royaltyPercentage;
        musicCost = _musicCost;
        members[msg.sender] = true;
        numberOfMembers=1;
    }

    function addRoyaltyPercentageProposal(string memory description, uint _percentageProposed) public returns(RoyaltyPercentageProposal memory){
        require(members[msg.sender], "Only members can add proposals");
        numRoyaltyProposals++;
        royaltyProposals[numRoyaltyProposals] = RoyaltyPercentageProposal(numRoyaltyProposals, description, 0, _percentageProposed, false);
        return royaltyProposals[numRoyaltyProposals];
    }

    function addMusicCostProposal(string memory _description, uint _value) public returns(MusicCostProposal memory){
        require(members[msg.sender], "Only members can add proposals");
        numMusicCostProposals++;
        musicCostProposals[numMusicCostProposals] = MusicCostProposal(numMusicCostProposals, _description, 0, _value, false);
        return musicCostProposals[numMusicCostProposals];
    }

    //getProposal by id

    function voteOnRoyaltyProposal(uint proposalId) public {
        require(members[msg.sender], "Only members can vote");
        require(!royaltyProposals[proposalId].executed, "Proposal has already been executed");
        require(!hasVotedRoyaltyPercentage[proposalId][msg.sender], "Yo have already voted");
        hasVotedRoyaltyPercentage[proposalId][msg.sender]=true;
        royaltyProposals[proposalId].votes++;
    }

    function voteOnMusicCostProposal(uint proposalId) public {
        require(members[msg.sender], "Only members can vote");
        require(!musicCostProposals[proposalId].executed, "Proposal has already been executed");
        require(!hasVotedMusicCost[proposalId][msg.sender], "Yo have already voted");
        hasVotedMusicCost[proposalId][msg.sender]=true;
        musicCostProposals[proposalId].votes++;
    }

    function executeRoyaltyProposal(uint proposalId) public {
        require(royaltyProposals[proposalId].votes >= numberOfMembers/2, "Quorum not reached");
        require(!royaltyProposals[proposalId].executed, "Proposal has already been executed");
        royaltyProposals[proposalId].executed = true;
        royaltyPercentageArtist = royaltyProposals[proposalId].percentageProposed;
    }

    function executeMusicCostProposal(uint proposalId) public {
        require(musicCostProposals[proposalId].votes >= numberOfMembers/2, "Quorum not reached");
        require(!musicCostProposals[proposalId].executed, "Proposal has already been executed");
        musicCostProposals[proposalId].executed = true;
        musicCost = musicCostProposals[proposalId].cost;
    }

    function addMember(address newMember) public {
        require(members[msg.sender], "Only members can add new members");
        members[newMember] = true;
    }

    function getRoyaltyPercentage() public view returns(uint){
        return royaltyPercentageArtist;
    }

    function getMusicCost() public view returns(uint){
        return musicCost;
    }
}