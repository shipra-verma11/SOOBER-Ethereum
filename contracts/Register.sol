pragma solidity ^0.5.0;

contract Register{
   
    /*Contract for User registration & login*/
   
    /*Registration for Rider*/
    struct RiderInfo{
        string name;
        string phone;
    }
   
    mapping(address=>RiderInfo) RiderList;
    mapping(address=>bool) RiderAlreadyRegistered;
   
   /*Rider has to register first*/
    function registerAsRider(string memory _name, string memory _phone) public{
        require(RiderAlreadyRegistered[msg.sender]==false,"Rider has already registered!");
       
        RiderAlreadyRegistered[msg.sender] = true;
        RiderList[msg.sender] = RiderInfo(_name, _phone);
    }
   
    function Riderlogin() public view returns(string memory){
         require(RiderAlreadyRegistered[msg.sender] == true, "User does not exist");
       
        return (RiderList[msg.sender].name);
    }
   
   /*To get the rider details after ride accepted */
    function getRiderDetails(address _rider) public view returns(string memory, string memory){
        RiderInfo memory details = RiderList[_rider];
        return (details.name, details.phone);
    }
   
   /*Registration for driver*/
    struct VehicleInfo{
        string vehNum;  //vehicle number
        string vehType; //type of vehicle mini, micro or SUV
        string vehModel;
        uint capacity;  //number of seats
    }
   
    struct DriverInfo{
        string name;
        string phone;   //contact
        //vehicle details
        VehicleInfo vehicle;
    }
   
    mapping(address=>DriverInfo) DriverList;
    mapping(address=>bool) DriverAlreadyRegistered;
   
   /*Driver has to register first*/
    function registerAsDriver(string memory _name, string memory _phone, string memory _vehNum, string memory _vehType, string memory _vehModel, uint _seats) public{
        require(DriverAlreadyRegistered[msg.sender]==false,"Driver has already registered!");
       
        DriverAlreadyRegistered[msg.sender] = true;
        DriverList[msg.sender] = DriverInfo(_name, _phone, VehicleInfo(_vehNum, _vehType, _vehModel, _seats));
    }
   
    function Driverlogin() public view returns(string memory){
        require(DriverAlreadyRegistered[msg.sender] == true, "Driver has to register first");
       
        return (DriverList[msg.sender].name);
    }
   
   /*To get the Driver details for the ride*/
    function getDriverDetails(address _driver) public view returns(string memory, string memory, string memory, string memory, string memory, uint){
        require(DriverAlreadyRegistered[_driver] == true, "User does not exist");
        DriverInfo memory details = DriverList[_driver];
       
        return (details.name, details.phone, details.vehicle.vehNum, details.vehicle.vehType, details.vehicle.vehModel, details.vehicle.capacity);
    }
    
    /*checks if the user is registered*/
    function is_rider(address _user) public view returns(bool){
        return RiderAlreadyRegistered[_user];
    }

    function is_driver(address _user) public view returns(bool){
        return DriverAlreadyRegistered[_user];
    }
}