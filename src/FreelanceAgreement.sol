// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract
// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions
// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/* Imports */

/**
 * @title Freelance Platform Agreement Contract
 * @author Kshitij Dhamanikar
 * @notice This contract is for creating an escrow between the Client and Freelancer
 */

contract FreelanceAgreement {
    /* Errors */
    error FreelanceAgreement__IncorrectStakingAmount();

    /* Type declarations */
    enum Project_Status {
        Initiated,
        Active,
        Completed,
        Cancelled
    }

    struct ContractDetails {
        address payable ClientAddress;
        address payable FreelancerAddress;
        address ContractAddress; // The Address of the Contract between Client & Freelancer
        uint256 ProjectPrice;
        uint256 NumberOfMilestones;
        uint256 CurrentMilestone;
        uint256 MilestonePayment;
        uint256 NumberOfMilestonesCompleted;
        string ProjectTitle;
        string ProjectDescription;
        bool ClientStake;
        Project_Status projectStatus;
    }

    ContractDetails public contractDetails;

    /* State Variables */
    bool public ClientCancelAgreement;
    bool public FreelancerCancelAgreement;

    Project_Status public projectStatus;

    /* Events */

    /* Modifiers */
    modifier OnlyClient() {
        require(
            msg.sender == contractDetails.ClientAddress,
            "CLIENT IS THE ONLY ONE ALLOWED!"
        );
        _;
    }

    modifier OnlyFreelancer() {
        require(
            msg.sender == contractDetails.FreelancerAddress,
            "FREELANCER IS THE ONLY ONE ALLOWED!"
        );
        _;
    }

    modifier Both_ClientAndFreelancer() {
        require(
            msg.sender == contractDetails.ClientAddress ||
                msg.sender == contractDetails.FreelancerAddress,
            "You are NOT the CLIENT OR FREELANCER"
        );
        _;
    }

    modifier ActiveProjectState() {
        require(
            projectStatus == Project_Status.Initiated,
            "PROJECT IS NOT INITIATED!"
        );
        _;
    }

    /* Functions */
    constructor(
        address payable _Client,
        address payable _Freelancer,
        uint256 _ProjectPrice,
        uint256 _NumberOfMilestones,
        string memory _ProjectTitle,
        string memory _ProjectDescription
    ) {
        require(
            _Client != _Freelancer,
            "Client Address and Freelancer Address can't be the same"
        ); // Checking if the Client & Freelancer have the same Wallet Address

        contractDetails = ContractDetails({
            ClientAddress: _Client,
            FreelancerAddress: _Freelancer,
            ProjectPrice: _ProjectPrice,
            NumberOfMilestones: _NumberOfMilestones,
            ProjectTitle: _ProjectTitle,
            ProjectDescription: _ProjectDescription,
            MilestonePayment: (_ProjectPrice / _NumberOfMilestones),
            projectStatus: Project_Status.Initiated,
            ContractAddress: address(this),
            CurrentMilestone: 0,
            NumberOfMilestonesCompleted: 0,
            ClientStake: false
        });

        ClientCancelAgreement = false;
        FreelancerCancelAgreement = false;
    }

    function StakeMoney() public payable OnlyClient ActiveProjectState {
        if (msg.value != contractDetails.ProjectPrice) {
            revert FreelanceAgreement__IncorrectStakingAmount();
        }
    } // client

    function Cancel() public {} // both client & freelancer

    function WithdrawMoney() public OnlyFreelancer {}

    function getStatus() public {}
}
