// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract bankKYCpgprojkt {

address KYCadmin;

struct Bank {
    string BankName;
    address BankAddress;
    bool CanAddCustomer;
    bool CanDoKYC;
}

struct Customer {
    string CustomerName;
    string CustomerData;
    address CustomerBank;
    bool KYCstatus;
}

mapping  (address => Bank) BankInfo;
mapping (string => Customer) CustomerInfo;


//SETS THE KYC_ADMIN as the SUPER ADMIN ABOVE THE BANK LEVEL
// done right even before executing the smart contract.
constructor() {
    KYCadmin = msg.sender;
}

modifier OnlyKYCadmin {
    require(msg.sender == KYCadmin, "Only KYC Admin allowed");
    _;
}
    
modifier OnlyIfBankExists (address _BankAddress) {
    require(BankInfo[_BankAddress].BankAddress!=address(0), "Bank not found");
    _;
}

modifier OnlyIfBankAllowedforKYC {
    require(BankInfo[msg.sender].CanDoKYC, "Bank not allowed to do KYC");
    _;
}
    

modifier OnlyIfBankAllowedToAddCustomer {
        require(BankInfo[msg.sender].CanAddCustomer, "This Bank not allowed to add Customer");
    _;
}

//check STRINGS SAME CHECK, PRIVATE because we do not want access from outside , and PURE because unlike we do not need to go to the blockchain for reading STATE
// data, this function will run only in the memory for the code of this function.
// FIRST we check the length of the two STRINGS and then we use GLOBALLY available keccak256 hashing to check if the two hashes produced are 
// are same or not, thus sameness of the hash implies the sameness of the two strings. 
function CompareTwoStringsSameOrNot (string memory _string1, string memory _string2) private pure returns (bool) {
    if (bytes(_string1).length != bytes(_string2).length) {
        return false;
    } else {
        return keccak256(bytes(_string1)) == keccak256(bytes(_string2));
    }
}


function AddNewBank (string memory _BankName, address _BankAddress) public OnlyIfBankExists(_BankAddress) OnlyKYCadmin {
    require(!CompareTwoStringsSameOrNot(BankInfo[_BankAddress].BankName, _BankName), "Bank with the same name already exists");
    BankInfo[_BankAddress]=Bank(_BankName, _BankAddress, 0, true, true);
}

// WE AUTOMATICALLY USE THE ADDRESS OF THE ADDING BANK as the ADDRESS for the CUSTOMER assuming the BANK IN THAT AREA/ADDRESS is allowed to add 
// customer from his area. 
function AddNewCustomer (string memory _CustomerName, string memory _CustomerData) public OnlyIfBankAllowedToAddCustomer {
    CustomerInfo[_CustomerName]=Customer(_CustomerName, _CustomerData, msg.sender, false);
}

function BlockBankfromAddingCustomer (address _BankAddress) public OnlyIfBankExists(_BankAddress) OnlyKYCadmin {
    BankInfo[_BankAddress].CanAddCustomer=false;
}

function AllowBankfromAddingCustomer (address _BankAddress) public OnlyIfBankExists(_BankAddress) OnlyKYCadmin {
    BankInfo[_BankAddress].CanAddCustomer=true;
}

function BlockBankfromDoingKyc (address _BankAddress) public OnlyIfBankExists(_BankAddress) OnlyKYCadmin {
    BankInfo[_BankAddress].CanDoKYC=false;
}

function AllowBankfromDoingKyc (address _BankAddress) public OnlyIfBankExists(_BankAddress) OnlyKYCadmin {
    BankInfo[_BankAddress].CanDoKYC=true;
}

//validating if BANK ALLOW TO PERFOMR KYC OR NOT: 
function PerformKYC (string memory _CustomerName) public OnlyIfBankAllowedforKYC {
    CustomerInfo[_CustomerName].KYCstatus=true;
}


// since getter function only reading involved from the blockchain, therfore only VIEW 
function ViewCustomerData (string memory _CustomerName) public view returns(string memory, bool) {
    return(CustomerInfo[_CustomerName].CustomerData, CustomerInfo[_CustomerName].KYCstatus);
}

}