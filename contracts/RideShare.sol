pragma solidity ^0.5.0;

import "./Register.sol";

contract RideShare{
    
    Register reginstance;
   
    constructor(address RegisterAddr) public{
        reginstance = Register(RegisterAddr);
    }
    
    event LogListingAdded(address sender, uint id, uint farePerKM, string locaiton);
    event LogTripStarted(address passenger, address driver, uint payment,
        string destination, uint kilometers);
    event LogTripCompleted(address passenger, address driver, uint payment,
        uint kilometers);
    event price(uint256 fare, uint256 amount);
    
    /*struct for rideshare details*/
    struct Ride {
        uint farePerKM;
        string location;
        uint lockedAmount;
        address payable driverAddr;
        address payable passengerAddr;
    }
    
    mapping(uint256 => Ride) rideList;
    
    
    mapping (address => uint256) deposits;
    
    uint listingsCnt;
    
    mapping(address => uint256) Driver_review;
    mapping(address => uint256) Rider_review;
    
    /*Driver adding riding details*/
    function addRideList(uint _farePerKM, string memory _location)
        public returns(bool)
    {
       require(reginstance.is_driver(msg.sender) == true); //checks the driver is registered
        
        listingsCnt = listingsCnt + 1;
        rideList[listingsCnt] = Ride({
                farePerKM: _farePerKM,
                location: _location,
                lockedAmount: 0,
                driverAddr: msg.sender,
                passengerAddr: address(0)
            });

        emit LogListingAdded(msg.sender, listingsCnt, _farePerKM, _location);
        return true;
    }
    
    /*To show all the rides available with FarePerKM and driver location*/
    function showRidesAvailable() public view returns(uint256){
        require(reginstance.is_rider(msg.sender) == true);  //only rider can view
        
        return listingsCnt;
    }
    
    function showRideDeatils(uint id) public view returns(uint, string memory, address)
    {
        require(reginstance.is_rider(msg.sender) == true);  //only rider can view
        
        Ride memory rideDetails = rideList[id];
        
        return (rideDetails.farePerKM, rideDetails.location, rideDetails.driverAddr);
    }
    
    /*Ride accepted by the rider*/
    /*Rider has to deposit the estimate fare*/
    function startTrip(uint id, uint KM, string memory destination)
        public payable
        returns (bool)
    {
        require(reginstance.is_rider(msg.sender) == true);
        require(listingExists(id));
        require(listingAvailable(id));
        
        uint256 requiredAmount = getEstimateFare(id, KM);
        
       require((requiredAmount * (10**18)) == msg.value, "Deposit correct amount"); //checks the correct amount is paid

        
        uint256 amount = msg.value;
        address payee = rideList[id].driverAddr;
        deposits[payee] = deposits[payee] + amount;         //Escrow

        rideList[id].lockedAmount = requiredAmount;
        rideList[id].passengerAddr = msg.sender;

        emit LogTripStarted(msg.sender, rideList[id].driverAddr, requiredAmount, destination, KM);
        return true;
    }
    
    /*internal function to calculate estimate fare*/
    function getEstimateFare(uint id, uint KM) internal view returns (uint256)
    {
        uint256 requiredAmount = KM * rideList[id].farePerKM;
        
        return requiredAmount;
    }
    
    /*checks the driver exists or not*/
    function listingExists(uint id)
        internal
        view
        returns (bool)
    {
        return (rideList[id].driverAddr != address(0));
    }

    /*checks the driver is available for the ride*/
    function listingAvailable(uint id)
        internal
        view
        returns (bool)
    {
        return (rideList[id].lockedAmount == 0);
    }
    
    /*function is called by the rider when trip is completed*/
    function completeTrip(uint id, uint totalKM)
        public
        returns (bool)
    {
        require(listingExists(id));

        uint totalAmount = totalKM * rideList[id].farePerKM;
        if (totalAmount > rideList[id].lockedAmount)
            totalAmount = rideList[id].lockedAmount;

        address payable payee = rideList[id].driverAddr;
        address payable payer = rideList[id].passengerAddr;
        uint256 remainingAmount = deposits[payee] - totalAmount;    //if actual amount is less than estimate 
                                                                    //then remaining amount transferred back to rider's account
        deposits[payee] = 0;
        payer.transfer(remainingAmount);

        payee.transfer(totalAmount);

        rideList[id].lockedAmount = 0;
        rideList[id].passengerAddr = address(0);

        emit LogTripCompleted(msg.sender, rideList[id].driverAddr, totalAmount, totalKM);
        return true;
    }
    
    /*function called by rider to cancel the ride*/
    function cancelTrip(uint id)
        public
        returns (bool)
    {
        require(listingExists(id));

        address payable payee = rideList[id].driverAddr;
        address payable payer = rideList[id].passengerAddr;
        
        deposits[payee] = 0;
        payer.transfer(rideList[id].lockedAmount);              //deposit amount transferred back to rider's account

        rideList[id].lockedAmount = 0;
        rideList[id].passengerAddr = address(0);
        
        return true;
    }
    
    /*function is called after the trip is completed*/
    /*Driver can review the rider*/
    function review_rider(address _rider, uint _review) public returns (bool) {
        require(
            _review >= 0 && _review <= 100, "review must be between 0 and 100"
            );
        
        if(Rider_review[_rider] == 0) {
            Rider_review[_rider] = _review;
        }
        else {
        Rider_review[_rider] = (Rider_review[_rider] + _review) / 2;
        }
    }
    
    /*function is called after the trip is completed*/
    /*Rider can review the driver*/
    function review_driver(address _driver, uint _review) public returns (bool) {
        require(
            _review >= 0 && _review <= 100, "review must be between 0 and 100"
            );
        
        if(Driver_review[_driver] == 0) {
            Driver_review[_driver] = _review;
        }
        else {
        Driver_review[_driver] = (Driver_review[_driver] + _review) / 2;
        }
    }
    
    /*Review is visible in the user details before starting the ride*/
    function get_review(address _user) public view returns (uint256) {
        if(reginstance.is_rider(msg.sender) == true){
            require(reginstance.is_driver(_user) == true, "only rider can get driver's review");
            return (Driver_review[_user]);
        }
        
        if(reginstance.is_driver(msg.sender) == true){
            require(reginstance.is_rider(_user) == true, "only driver can get rider's review");
            return (Rider_review[_user]);
        }
    }
    
}