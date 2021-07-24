// contracts/NFTplanet.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../contracts/IArbitrator.sol"

contract PlanetNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter public totalPlanets;
    mapping (address => uint256[]) planetsIds;

    event NewPlanet(uint256 id);

    struct Planet {
        uint256 p;
        uint256 r;
        uint256 a;
        uint256 id;
        address owner;
        NftArt[] allNfts;
    }

    struct NftArt{
        address contractAddress;
        uint256 id;
    }

    constructor() ERC721("PlanetNFT", "PNFT") {}

    function mintPlanet(address player, string memory tokenURI) public returns (uint256)
    {
        uint256 newPlanetId = totalPlanets.current();
        totalPlanets.increment();

        _mint(player, newPlanetId);

        _setTokenURI(newPlanetId, tokenURI);

        emit NewPlanet(newPlanetId);

        return newPlanetId;
    }


    function getParam() public view returns (uint256 r, uint256 p, uint256 a)
    {

        r = 21;
        p = 0;
        a = 2;
    }

    function updatePosition (address player, uint256 _tokenID) public returns (uint256 r, uint256 p, uint256 a){
    {

    }




/**
 *  @authors: [@clesaege, @n1c01a5, @epiqueras, @ferittuncer]
 *  @reviewers: [@clesaege*, @unknownunknown1*]
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 *  @tools: [MythX]
 */

pragma solidity ^0.4.15;

import "./Arbitrator.sol";

/** @title Centralized Arbitrator
 *  @dev This is a centralized arbitrator deciding alone on the result of disputes. No appeals are possible.
 */
contract CentralizedArbitrator is Arbitrator {

    address public owner = msg.sender;
    uint arbitrationPrice; // Not public because arbitrationCost already acts as an accessor.
    uint constant NOT_PAYABLE_VALUE = (2**256-2)/2; // High value to be sure that the appeal is too expensive.

    struct DisputeStruct {
        Arbitrable arbitrated;
        uint choices;
        uint fee;
        uint ruling;
        DisputeStatus status;
    }

    struct LocationStruct {
        uint choices;
        uint r;
        uint p;
        uint a;
        LocationStatus status;
    }

    modifier onlyOwner {require(msg.sender==owner, "Can only be called by the owner."); _;}
    modifier onlyLocation {require(coordinates(location) <= locations.choices, "Invalid location.");}

    DisputeStruct[] public disputes;
    LocationStruct[] public locations;
    /* @if Arbitrable planetIDs location are within LocationStruct.


    /** @dev Constructor. Set the initial arbitration price.
     *  @param _arbitrationPrice Amount to be paid for arbitration.
     */
    constructor(uint _arbitrationPrice) public {
        arbitrationPrice = _arbitrationPrice;
    }

    /** @dev Constructor. Set the initial coordinates for the arbitration area.
     *  @param r,p,a. Represents coordinates of the area in which createDispute can be called.
     NFTS which have coordinate values smaller than r,p,or a, are considered to be within the arbitrable area.
     */
    constructor(uint r, p, a) public {
        r = r;
        p = p;
        a = a;
    }

    /** @dev Set the arbitration price. Only callable by the owner.
     *  @param _arbitrationPrice Amount to be paid for arbitration.
     */
    function setArbitrationPrice(uint _arbitrationPrice) public onlyOwner {
        arbitrationPrice = _arbitrationPrice;
    }

    /** @dev Cost of arbitration. Accessor to arbitrationPrice.
     *  @param _extraData Not used by this contract.
     *  @return fee Amount to be paid.
     */
    function arbitrationCost(bytes _extraData) public view returns(uint fee) {
        return arbitrationPrice;
    }

    /** @dev Cost of appeal. Since it is not possible, it's a high value which can never be paid.
     *  @param _disputeID ID of the dispute to be appealed. Not used by this contract.
     *  @param _extraData Not used by this contract.
     *  @return fee Amount to be paid.
     */
    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee) {
        return NOT_PAYABLE_VALUE;
    }

     /** @dev Create a dispute. Must be called by the arbitrable contract.
      *  Must be paid at least arbitrationCost().
      *  @param _choices Amount of choices the arbitrator can make in this dispute. When ruling ruling<=choices.
      *  @param _extraData Can be used to give additional info on the dispute to be created.
      *  @return disputeID ID of the dispute created.
      */
     function createDispute(uint _choices, address nft_contract, uint256 nft_id ) public payable returns(uint disputeID)  {
         super.createDispute(_choices, nft_contract, nft_id);
       /*need to check whether the location of the NFT is within the arbitrable zone*/
         require(location.nft_id <= r || location.nft_id <= p, location.nft_id <= a, location.nft "Invalid ruling.");
        /*need to check whether the location of the NFT is within the arbitrable zone*/
          /*no function implemented to check the location of an NFT*/ 
         disputeID = disputes.push(DisputeStruct({
             arbitrated: Arbitrable(msg.sender),
             choices: _choices,
             fee: msg.value,
             ruling: 0,
             status: DisputeStatus.Waiting
             })) - 1; // Create the dispute and return its number.
         emit DisputeCreation(disputeID, Arbitrable(msg.sender));
     }


    /** @dev Give a ruling. UNTRUSTED.
     *  @param _disputeID ID of the dispute to rule.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 means "Not able/wanting to make a decision".
     */
    function _giveRuling(uint _disputeID, uint _ruling) internal {
        DisputeStruct storage dispute = disputes[_disputeID];
        require(_ruling <= dispute.choices, "Invalid ruling.");
        require(dispute.status != DisputeStatus.Solved, "The dispute must not be solved already.");

        dispute.ruling = _ruling;
        dispute.status = DisputeStatus.Solved;

        msg.sender.send(dispute.fee); // Avoid blocking.
        dispute.arbitrated.rule(_disputeID,_ruling);
    }

    /** @dev Give a ruling. UNTRUSTED.
     *  @param _disputeID ID of the dispute to rule.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 means "Not able/wanting to make a decision".
     */
    function giveRuling(uint _disputeID, uint _ruling) public onlyOwner {
        return _giveRuling(_disputeID, _ruling);
    }

    /** @dev Return the status of a dispute.
     *  @param _disputeID ID of the dispute to rule.
     *  @return status The status of the dispute.
     */
    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status) {
        return disputes[_disputeID].status;
    }

    /** @dev Return the ruling of a dispute.
     *  @param _disputeID ID of the dispute to rule.
     *  @return ruling The ruling which would or has been given.
     */
    function currentRuling(uint _disputeID) public view returns(uint ruling) {
        return disputes[_disputeID].ruling;
    }
}
