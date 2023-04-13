// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./GovDao.sol" as Gov;
import "./DataDAO.sol";

contract DecentralizedMusic is DataDAO{
    //using Encoding for bytes;
    Gov.GovDao govDAO;
    //IERC20 public artistToken;
    IERC20 public musicToken;
    IERC20 public daoToken;

    struct MusicFile {
        uint id;
        string cid;
        string title;
        address artist;
    }

    mapping(uint => MusicFile) private musicFiles;
    mapping(bytes => uint256) public dealStorageFees;
    mapping(bytes => uint64) public dealClient;
    uint numMusicFiles;

    event MusicFileAdded(string cid, string title, address artist);

    constructor(address[] memory admins,address _musicTokenAddress,address _govDAOAddress, address _daoToken) DataDAO(admins){
        govDAO = Gov.GovDao(_govDAOAddress);
        //artistToken = IERC20(_artistTokenAddress);
        musicToken = IERC20(_musicTokenAddress);
        daoToken = IERC20(_daoToken);
        numMusicFiles=0;
    }

    function joinDAO() public {
        require(daoToken.balanceOf(msg.sender) > 100, "You are not the holder of DataDAO NFT");
        addUser(msg.sender, MEMBER_ROLE);
    }

    function createDataSetDealProposal(bytes memory _cidraw, uint _size, uint256 _dealDurationInDays, uint256 _dealStorageFees) public payable {
        require(hasRole(MEMBER_ROLE, msg.sender), "Caller is not a minter");
        createDealProposal(_cidraw, _size, _dealDurationInDays);
        dealStorageFees[_cidraw] = _dealStorageFees;
    }

    function approveOrRejectDataSet(bytes memory _cidraw, DealState _choice) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not a admin");
        approveOrRejectDealProposal(_cidraw, _choice);
    }

    function activateDataSetDealBySP(uint64 _networkDealID) public {
        uint64 client = activateDeal(_networkDealID);
        MarketTypes.GetDealDataCommitmentReturn memory commitmentRet = MarketAPI.getDealDataCommitment(MarketTypes.GetDealDataCommitmentParams({id: _networkDealID}));
        dealClient[commitmentRet.data] = client;
    }

    function withdrawReward(bytes memory _cidraw) public {
        require(getDealState(_cidraw) == DealState.Expired);
        reward(dealClient[_cidraw], dealStorageFees[_cidraw]);
    }
 
    function addMusicFile(string memory cid, string memory title) public {
        //require(musicFiles[cid].cid != cid, "Music file already exists");
        numMusicFiles++;
        musicFiles[numMusicFiles] = MusicFile(numMusicFiles, cid, title, msg.sender);
        emit MusicFileAdded(cid, title, msg.sender);
    }

    function getMusicFile(uint id) public payable returns (string memory title, address artist, string memory conId) {
        require(id<=numMusicFiles, "Music file does not exist");
        MusicFile memory musicFile = musicFiles[id];
        uint ratio = govDAO.getMusicCost();
        uint royaltyPercentage = govDAO.getRoyaltyPercentage();

        musicToken.transferFrom(msg.sender, musicFile.artist, ratio);
        musicToken.transfer(musicFile.artist, royaltyPercentage*ratio/100);

        return (musicFile.title, musicFile.artist, musicFile.cid);
    }
}