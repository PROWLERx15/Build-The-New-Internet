// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Freelance Platform Agreement Contract
 * @author Kshitij Dhamanikar
 * @notice This contract creates an escrow between a Client and a Freelancer to manage payments for a project.
 * @dev This contract handles project state management, staking of funds by the client, and events for state changes.
 */

/* Imports */

contract FreelanceAgreement {
    /* Errors */

    /// @notice Thrown when the amount staked by the client does not match the required project price.
    error FreelanceAgreement__IncorrectStakingAmount();

    /// @notice Thrown when the client attempts to stake money after already staking.
    error FreelanceAgreement__AlreadyStakedMoney();

    /// @notice Thrown when the project state does not match the expected state for a particular function or operation.
    error FreelanceAgreement__IncorrectProjectState();

    /* Type declarations */

    /**
     * @notice Enumeration to represent the various states a project can be in.
     * @dev Used to track the current status of the project in the contract.
     */
    enum Project_Status {
        Initiated, ///< Project has been initiated but not yet started.
        Active, ///< Project is currently active and ongoing.
        Completed, ///< Project has been completed successfully.
        Cancelled ///< Project has been cancelled by either party.
    }

    /**
     * @notice A struct containing all the details related to the contract between the Client and Freelancer.
     * @dev This struct holds essential information such as addresses, project price, milestones, and status.
     */
    struct ContractDetails {
        address payable ClientAddress; ///< Address of the client.
        address payable FreelancerAddress; ///< Address of the freelancer.
        address ContractAddress; ///< The address of this contract instance.
        uint256 ProjectPrice; ///< Total price agreed upon for the project.
        uint256 NumberOfMilestones; ///< Total number of milestones in the project.
        uint256 CurrentMilestone; ///< Index of the current milestone being worked on.
        uint256 MilestonePayment; ///< Payment allocated for each milestone.
        uint256 NumberOfMilestonesCompleted; ///< Number of milestones completed so far.
        string ProjectTitle; ///< Title of the project.
        string ProjectDescription; ///< Description of the project.
        bool ClientStake; ///< Indicates whether the client has staked the project price.
        Project_Status projectStatus; ///< Current status of the project.
    }

    ContractDetails private contractDetails; ///< Instance of the ContractDetails struct storing the contract's information.

    /* State Variables */

    bool private ClientCancelAgreement; ///< Indicates if the client has canceled the agreement.
    bool private FreelancerCancelAgreement; ///< Indicates if the freelancer has canceled the agreement.

    Project_Status public projectStatus; ///< Current status of the project, duplicated for easy access.

    /* Events */

    /**
     * @notice Emitted when the project status changes.
     * @param client The address of the client.
     * @param freelancer The address of the freelancer.
     * @param status The new status of the project.
     */
    event ContractStateChanged(
        address indexed client,
        address indexed freelancer,
        Project_Status status
    );

    /* Modifiers */

    /**
     * @notice Modifier to restrict functions to only be called by the client.
     * @dev Ensures that only the client can execute the functions it modifies.
     */
    modifier OnlyClient() {
        require(
            msg.sender == contractDetails.ClientAddress,
            "CLIENT IS THE ONLY ONE ALLOWED!"
        );
        _;
    }

    /**
     * @notice Modifier to restrict functions to only be called by the freelancer.
     * @dev Ensures that only the freelancer can execute the functions it modifies.
     */
    modifier OnlyFreelancer() {
        require(
            msg.sender == contractDetails.FreelancerAddress,
            "FREELANCER IS THE ONLY ONE ALLOWED!"
        );
        _;
    }

    /**
     * @notice Modifier to allow functions to be called only by either the client or the freelancer.
     * @dev Ensures that only the client or the freelancer can execute the functions it modifies.
     */
    modifier Both_ClientAndFreelancer() {
        require(
            msg.sender == contractDetails.ClientAddress ||
                msg.sender == contractDetails.FreelancerAddress,
            "You are NOT the CLIENT OR FREELANCER"
        );
        _;
    }

    /**
     * @notice Modifier to restrict function execution based on the current project status.
     * @dev Ensures that the function is only executed if the project is in the specified state.
     * @param _status The required project status for the function to execute.
     */
    modifier CurrentProjectState(Project_Status _status) {
        if (projectStatus == _status) {
            revert FreelanceAgreement__IncorrectProjectState();
        }
        _;
    }

    /* Functions */

    /**
     * @notice Constructor to initialize the contract with client and freelancer details, project price, and milestones.
     * @dev The contract details are set up upon deployment, and the project is marked as initiated.
     * @param _Client The address of the client.
     * @param _Freelancer The address of the freelancer.
     * @param _ProjectPrice The total price of the project in wei.
     * @param _NumberOfMilestones The total number of milestones for the project.
     * @param _ProjectTitle The title of the project.
     * @param _ProjectDescription The description of the project.
     */
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

        // Initialize the contract details with the provided parameters.
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

    /**
     * @notice Allows the client to stake the agreed project price into the contract.
     * @dev The function ensures that the correct amount is staked and that the client cannot stake more than once. It also transitions the project state to Active.
     * @custom:calledby Client
     * @custom:modifiers OnlyClient, CurrentProjectState(Project_Status.Initiated)
     * @custom:error FreelanceAgreement__IncorrectStakingAmount Thrown if the staked amount does not match the project price.
     * @custom:error FreelanceAgreement__AlreadyStakedMoney Thrown if the client tries to stake money again.
     */
    function StakeMoney()
        public
        payable
        OnlyClient
        CurrentProjectState(Project_Status.Initiated)
    {
        if (msg.value != contractDetails.ProjectPrice) {
            revert FreelanceAgreement__IncorrectStakingAmount();
        }
        if (contractDetails.ClientStake) {
            revert FreelanceAgreement__AlreadyStakedMoney();
        }
        contractDetails.ClientStake = true;
        projectStatus = Project_Status.Active;
        emit ContractStateChanged(
            contractDetails.ClientAddress,
            contractDetails.FreelancerAddress,
            projectStatus
        );
    }

    /**
     * @notice Allows the client or freelancer to cancel the contract.
     * @dev This function should include logic to handle the cancellation of the contract and return funds if applicable.
     */
    function Cancel() public {
        // Function logic to be implemented.
    }

    /**
     * @notice Allows the freelancer to withdraw funds after completing milestones or the entire project.
     * @dev This function should include logic to allow withdrawal of funds based on the completion of milestones or project completion.
     * @custom:calledby Freelancer
     * @custom:modifiers OnlyFreelancer
     */
    function WithdrawMoney() public OnlyFreelancer {
        // Function logic to be implemented.
    }

    function payByMilestones() public {}

    function payAtOnce() public {}

    /**
     * @notice Returns the current status of the project.
     * @dev This function can be used to retrieve the status of the project at any given time.
     * @return The current project status.
     */
    function getStatus() public view returns (Project_Status) {
        return projectStatus;
    }

    /**
     * @notice Returns the full contract details encapsulated in a `ContractDetails` struct.
     * @dev This function provides a complete view of the contract's state by returning the entire `ContractDetails` struct.
     * @return contractDetails The `ContractDetails` struct containing all relevant information about the contract, including addresses, project details, and status.
     */
    function getContractDetails() public view returns (ContractDetails memory) {
        return contractDetails;
    }
}
