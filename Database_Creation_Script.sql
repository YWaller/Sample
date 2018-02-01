DROP DATABASE IF EXISTS `OAG_Club`;
CREATE DATABASE OAG_Club;
USE OAG_Club;
CREATE TABLE Customer (customer_ID INT, Name VARCHAR(50), Home_Phone VARCHAR(10), Work_Phone VARCHAR(10), DOB DATE, Address VARCHAR(50), Customer_Type VARCHAR(50), Sponsor_ID INT, PRIMARY KEY(customer_ID));

CREATE TABLE Signups (Customer_ID INT, Instance_ID INT, Insurance_Form BOOLEAN, PRIMARY KEY (Customer_ID, Insurance_Form, Instance_ID));

CREATE TABLE Trip_Instance (Instance_ID INT, Trip_Date DATE, Trip_ID INT, Employee_Leader_ID INT, Employee_assistant_ID INT,PRIMARY KEY(Trip_ID));

CREATE TABLE Trip_Type (Trip_ID INT, Trip_Name VARCHAR(50), DIFF_lvl INT, Trip_Fee INT, Trip_Length INT, PRIMARY KEY (Trip_ID));

CREATE TABLE Rental_Agreement (Agreement_Number INT, Start_Date DATE, customer_ID INT, employee_ID INT, PRIMARY KEY (Agreement_Number));

CREATE TABLE Rental_Detail (Expected_Return DATE, Real_Return DATE, item_number INT, agreement_num INT, PRIMARY KEY (agreement_num));

CREATE TABLE Inventory (Item_Number INT, `Condition` VARCHAR(50), equip_name VARCHAR(50), PRIMARY KEY (Item_Number));

CREATE TABLE Equipment (Equip_Name VARCHAR(50), Student_Fee FLOAT, FacStaffAl_Fee FLOAT, Guest_Fee FLOAT, PRIMARY KEY (Equip_Name));

CREATE TABLE OAG_Employee (Employee_ID INT, Employee_Name VARCHAR(50), Start_Date DATE, End_Date DATE, Position_ID INT, PRIMARY KEY (Employee_ID));

CREATE TABLE Position (Position_ID INT, Position_Descr VARCHAR(50), Position_Salary FLOAT, PRIMARY KEY (Position_ID));


set foreign_key_checks=0;
ALTER TABLE Trip_Instance ADD CONSTRAINT Instance_ID_uq UNIQUE (Instance_ID);
ALTER TABLE inventory ADD FOREIGN KEY (equip_name) REFERENCES equipment(equip_name);
ALTER TABLE customer ADD FOREIGN KEY (sponsor_ID) REFERENCES customer(customer_ID);
ALTER TABLE signups ADD FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID);
ALTER TABLE signups ADD FOREIGN KEY (Instance_ID) REFERENCES Trip_Instance(Instance_ID); 
ALTER TABLE trip_instance ADD FOREIGN KEY (Trip_ID) REFERENCES Trip_Type(Trip_ID); 
ALTER TABLE trip_instance ADD FOREIGN KEY (Employee_Leader_ID) REFERENCES OAG_Employee(Employee_ID);
ALTER TABLE trip_instance ADD FOREIGN KEY (Employee_Assistant_ID) REFERENCES OAG_Employee(Employee_ID);
ALTER TABLE rental_agreement ADD FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE rental_agreement ADD FOREIGN KEY (employee_id) REFERENCES oag_employee(employee_id);
ALTER TABLE rental_detail ADD FOREIGN KEY (item_number) REFERENCES inventory(item_number);
ALTER TABLE rental_detail ADD FOREIGN KEY (agreement_num) REFERENCES rental_agreement(agreement_number);
ALTER TABLE oag_employee ADD FOREIGN KEY (position_ID) REFERENCES `position`(position_ID);

INSERT INTO `Customer` (`customer_ID`, `Name`, `home_phone`, `work_phone`, `DOB`, `Address`, `Customer_type`, `Sponsor_ID`) VALUES (1,  'Frodo Baggins', '7035234456', '2025345443','1990-09-22', '500 Underhill Lane', 'Student', NULL);

INSERT INTO `Customer` (`customer_ID`, `Name`, `home_phone`, `work_phone`, `DOB`, `Address`, `Customer_type`, `Sponsor_ID`) VALUES (2, 'Harry Potter', '7573241826', '7034678901','1986-07-31', '4 Privet Drive', 'Student', null );

INSERT INTO `Customer` (`customer_ID`, `Name`,`home_phone`, `work_phone`, `DOB`, `Address`, `Customer_type`, `Sponsor_ID`) VALUES (3,'Gandalf', '7034231341', '7571004323','1900-04-12', '121 Horsecart Drive', 'Faculty', null);

INSERT INTO `Customer` (`customer_ID`, `Name`, `home_phone`, `work_phone`, `DOB`, `Address`, `Customer_type`, `Sponsor_ID`) VALUES (4, 'Hermione Granger', '8034167845', '6123987623', '1985-05-23', '24 Pine Rd', 'Guest', 2);

INSERT INTO `Customer` (`customer_ID`, `Name`, `home_phone`, `work_phone`, `DOB`, `Address`, `Customer_type`, `Sponsor_ID`) VALUES (5, 'Ronald Weasley', '8032313221', '6121317333', '1985-02-20', '1 Burrow Rd', 'Guest', 2);

Insert INTO `Signups` (`Customer_ID`, `Instance_ID`, `Insurance_Form`) VALUES (1, 1, 2);

Insert INTO `Signups` (`Customer_ID`, `Instance_ID`, `Insurance_Form`) VALUES (1, 1, 4);

Insert INTO `Signups` (`Customer_ID`, `Instance_ID`, `Insurance_Form`) VALUES (2, 2, 1);

Insert INTO `Signups` (`Customer_ID`, `Instance_ID`, `Insurance_Form`) VALUES (4, 3, 3);

Insert INTO `Trip_Instance` (`Instance_ID`, `Trip_Date`, `Trip_ID`, `Employee_Leader_ID`, `Employee_assistant_ID`) VALUES (1, '2015-08-05', 2, 4, 2); 

Insert INTO `Trip_Instance` (`Instance_ID`, `Trip_Date`, `Trip_ID`, `Employee_Leader_ID`, `Employee_assistant_ID`) VALUES (2, '2015-10-15', 3, 1, 3);

Insert INTO `Trip_Instance` (`Instance_ID`, `Trip_Date`, `Trip_ID`, `Employee_Leader_ID`, `Employee_assistant_ID`) VALUES (3, '2016-03-2', 1, 4, 2);

Insert INTO `Trip_Instance` (`Instance_ID`, `Trip_Date`, `Trip_ID`, `Employee_Leader_ID`, `Employee_assistant_ID`) VALUES (4, '2016-06-13', 4, 1, 3);

INSERT INTO `Trip_Type` (`Trip_ID`, `Trip_Name`, `DIFF_lvl`, `Trip_Fee`, `Trip_Length`) VALUES (1, 'Day Hike', 3, 25, 1) ;

INSERT INTO `Trip_Type` (`Trip_ID`, `Trip_Name`, `DIFF_lvl`, `Trip_Fee`, `Trip_Length`) VALUES (2, 'Camping', 5, 50, 3) ;

INSERT INTO `Trip_Type` (`Trip_ID`, `Trip_Name`, `DIFF_lvl`, `Trip_Fee`, `Trip_Length`) VALUES (3, 'Rock Climbing', 7, 30, 1) ;

INSERT INTO `Trip_Type` (`Trip_ID`, `Trip_Name`, `DIFF_lvl`, `Trip_Fee`, `Trip_Length`) VALUES (4, 'Kayaking', 5, 40, 2) ;

Insert INTO `rental_agreement`(`Agreement_number`, `Start_date`, `customer_id`, `employee_id`) Values(1, '2017-01-15', 1, 1);

Insert INTO `rental_agreement`(`Agreement_number`, `Start_date`, `customer_id`, `employee_id`) Values(2, '2017-01-16', 3, 2);

Insert INTO `rental_agreement`(`Agreement_number`, `Start_date`, `customer_id`, `employee_id`) Values(3, '2017-03-15', 2, 2);

Insert INTO `rental_agreement`(`Agreement_number`, `Start_date`, `customer_id`, `employee_id`) Values(4, '2017-04-20', 2, 2);


Insert INTO `rental_detail`(`Expected_Return`, `Real_Return`, `item_number`, `agreement_num`) Values('2017-01-29','2017-01-29',2,1);

Insert INTO `rental_detail`(`Expected_Return`, `Real_Return`, `item_number`, `agreement_num`) Values('2017-01-29','2017-01-29',3,4);

Insert INTO `rental_detail`(`Expected_Return`, `Real_Return`, `item_number`, `agreement_num`) Values('2017-01-29','2017-01-29',4,5);

Insert INTO `rental_detail`(`Expected_Return`, `Real_Return`, `item_number`, `agreement_num`) Values('2017-02-20','2017-03-01',13,3);

Insert INTO `rental_detail`(`Expected_Return`, `Real_Return`, `item_number`, `agreement_num`) Values('2017-03-19',null,10,2);


INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(1, 'Good', 'Rope');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(2, 'Poor', 'Rope');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(3, 'Excellent', 'One Person Tent');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(4, 'Good', 'Outdoor Gas Cooker');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(5, 'Good',  'Walking Stick');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(6, 'Good', 'Walking Stick');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(7, 'Poor', 'Rope');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(8, 'Excellent', 'Bug Out Bag');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(9, 'Poor', 'Bug Out Bag');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(10, 'Good','Walking Stick');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(11, 'Good','Kayak');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(12, 'Good','Kayak');

INSERT INTO `Inventory` (`Item_Number`, `Condition`, `Equip_Name`) VALUES(13, 'Good','One Person Tent');

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('One Person Tent', 15, 20, 30);

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('Kayak', 35, 45, 50);

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('Walking Stick', 10.50, 12, 15);

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('Bug Out Bag', 15, 20, 30);

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('Climbing Shoes', 6.50, 8.50, 10);

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('Rope', 4.50, 6.50, 8.50);

INSERT INTO `Equipment`(`Equip_Name`, `Student_Fee`, `FacStaffAl_Fee`, `Guest_Fee`) VALUES('Outdoor Gas Cooker', 25, 30, 40);

INSERT INTO `OAG_Employee` (`Employee_ID`, `Employee_Name`, `Start_Date`, `End_date`, `Position_ID`) VALUES (1, 'Sam Jones', '2015-03-05', null , 2);

INSERT INTO `OAG_Employee` (`Employee_ID`, `Employee_Name`, `Start_Date`, `End_date`, `Position_ID`) VALUES (4, 'Sam Jones', '2012-02-16', '2015-03-04', 5);

INSERT INTO `OAG_Employee` (`Employee_ID`, `Employee_Name`, `Start_Date`, `End_date`, `Position_ID`) VALUES (2, 'Betty White', '2012-06-01',null , 3);

INSERT INTO `OAG_Employee` (`Employee_ID`, `Employee_Name`, `Start_Date`, `End_date`, `Position_ID`) VALUES (3, 'Emma Watson', '2013-08-01', null , 4);

INSERT INTO `Position` (`Position_ID`, `Position_Descr`, `Position_Salary`) VALUES (1, 'Equipment Manager', 12);

INSERT INTO `Position` (`Position_ID`, `Position_Descr`, `Position_Salary`) VALUES (2, 'Project Coordinator', 20);

INSERT INTO `Position` (`Position_ID`, `Position_Descr`, `Position_Salary`) VALUES (3, 'Marketing Manager', 15);

INSERT INTO `Position` (`Position_ID`, `Position_Descr`, `Position_Salary`) VALUES (4, 'Event Coordinator', 20);

INSERT INTO `Position` (`Position_ID`, `Position_Descr`, `Position_Salary`) VALUES (5, 'Trip Leader', 10);





