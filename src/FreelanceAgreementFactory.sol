// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Freelance Agreement Factory Contract
 * @notice This contract is responsible for deploying instances of the FreelanceAgreement contract.
 * @dev It stores addresses of all deployed FreelanceAgreement contracts and provides functions to interact with them.
 */

/* Imports */
import {FreelanceAgreement} from "./FreelanceAgreement.sol";

contract FreelanceAgreementFactory {
    /* State Variables */

    /**
     * @notice Array to keep track of all deployed FreelanceAgreement contracts.
     * @dev Stores the addresses of all deployed instances of the FreelanceAgreement contract.
     */
    address[] public deployedAgreements;

    /**
     * @notice Mapping from client addresses to a mapping of freelancer addresses to their agreement addresses.
     */
    mapping(address => mapping(address => address[]))
        public clientToFreelancerAgreements;

    /* Events */

    /**
     * @notice Emitted when a new FreelanceAgreement contract is created.
     * @param client The address of the client in the agreement.
     * @param freelancer The address of the freelancer in the agreement.
     * @param price The total price of the project in wei.
     * @param numberOfMilestones The total number of milestones for the project.
     * @param agreementAddress The address of the newly deployed FreelanceAgreement contract.
     * @param title The title of the project.
     * @param description The description of the project.
     */
    event AgreementCreated(
        address indexed client,
        address indexed freelancer,
        uint256 price,
        uint256 numberOfMilestones,
        address indexed agreementAddress,
        string title,
        string description
    );

    /* Functions */

    /**
     * @notice Deploys a new FreelanceAgreement contract and stores its address.
     * @dev This function initializes the new contract with client and freelancer details, project price, milestones, and project title/description.
     * @param _Client The address of the client involved in the agreement.
     * @param _Freelancer The address of the freelancer involved in the agreement.
     * @param _ProjectPrice The total price of the project in wei.
     * @param _NumberOfMilestones The total number of milestones for the project.
     * @param _ProjectTitle The title of the project.
     * @param _ProjectDescription The description of the project.
     * @return The address of the newly deployed FreelanceAgreement contract.
     * @custom:emits Emits an event with the details of the new contract.
     */
    function createFreelanceAgreement(
        address payable _Client,
        address payable _Freelancer,
        uint256 _ProjectPrice,
        uint256 _NumberOfMilestones,
        string memory _ProjectTitle,
        string memory _ProjectDescription
    ) public returns (address) {
        // Deploy a new FreelanceAgreement contract
        FreelanceAgreement newAgreement = new FreelanceAgreement(
            _Client,
            _Freelancer,
            _ProjectPrice,
            _NumberOfMilestones,
            _ProjectTitle,
            _ProjectDescription
        );

        // Store the address of the newly deployed contract
        address agreementAddress = address(newAgreement);
        deployedAgreements.push(agreementAddress);
        clientToFreelancerAgreements[_Client][_Freelancer].push(
            agreementAddress
        );

        // Emit the AgreementCreated event
        emit AgreementCreated(
            _Client,
            _Freelancer,
            _ProjectPrice,
            _NumberOfMilestones,
            agreementAddress,
            _ProjectTitle,
            _ProjectDescription
        );

        // Return the address of the new contract
        return agreementAddress;
    }

    /**
     * @notice Returns the list of all deployed FreelanceAgreement contract addresses.
     * @dev This function provides a way to retrieve the addresses of all deployed FreelanceAgreement contracts.
     * @return An array of addresses of deployed FreelanceAgreement contracts.
     */
    function getDeployedAgreements() public view returns (address[] memory) {
        return deployedAgreements;
    }

    /**
     * @notice Returns the list of agreement addresses associated with a client and a specific freelancer.
     * @param _Client The address of the client.
     * @param _Freelancer The address of the freelancer.
     * @return An array of agreement addresses between the client and freelancer.
     */
    function getClientToFreelancerAgreements(
        address _Client,
        address _Freelancer
    ) public view returns (address[] memory) {
        return clientToFreelancerAgreements[_Client][_Freelancer];
    }
}
