/*Below are some queries I have created throughout my jobs and coursework, and at the bottom are excerpts from database creation scripts I have made.
These have been provided as demonstrations of my knowledge of how SQL works. I am familiar with a variety of different systems, from Oracle to Teradata to simple MySQL. */


/*query 1*/
/*Returns information about customers with a join*/
SELECT  e.customer_ID AS 'Sponsor ID', e.name, e.address, e.home_phone, e.customer_type 
FROM customer c JOIN customer e ON c.Sponsor_ID = e.customer_ID 
GROUP BY e.customer_ID 
HAVING COUNT(e.customer_ID >= 2);

/*query 2*/
/*Brings in results from several tables using a series of joins*/
SELECT DISTINCT C.customer_ID, C.`Name`, C.Home_Phone, C.Work_Phone, I.Item_Number, I.`condition`, I.equip_name
FROM customer C
INNER JOIN rental_agreement R ON C.customer_ID = R.customer_ID
INNER JOIN rental_detail E ON E.agreement_num = R.agreement_number
INNER JOIN inventory I ON E.Item_number = I.item_Number
WHERE E.real_return IS NULL AND (E.expected_return) <= Now() - 2;

/*query 3*/
/*Using an OR sort, find certain employee names*/
SELECT DISTINCT Employee_Name
FROM OAG_Employee
JOIN `position` on OAG_employee.Position_ID = `position`.position_id
WHERE `position`.position_descr = 'Project Coordinator' OR `position`.position_ID = 5
HAVING COUNT(oag_employee.employee_Name) = 2;

/*query 4*/
/*A simple query for ranged sorting.*/
SELECT COUNT(p.Strikeout) as 'Strikeouts', t.Team_ID as 'TeamID', t.Team_Name, t.Team_Region as 'Region'
FROM pitching p
INNER JOIN playermast l ON p.playerID = l.PlayerID
INNER JOIN teams t ON l.TeamID = t.Team_ID
WHERE t.Team_Win > 40 OR t.Team_Loss < 100
GROUP BY t.Team_ID
HAVING t.Team_Region = 'E'
ORDER BY COUNT(p.Strikeout) DESC;

/*query 5*/
/*Demonstrates use of group by and having.*/
SELECT customer.name, customer.address FROM rental_agreement 
JOIN customer ON rental_agreement.customer_ID = customer.customer_ID 
GROUP BY rental_agreement.customer_ID 
HAVING COUNT(rental_agreement.customer_ID) >= 2;

/*query 6*/
/*Demonstrates another group by and having.*/
SELECT m.mfname, m.mlname, m.msalary, m.mbdate, count(*) as 'Buildings Managed'
FROM manager m, building b
WHERE m.managerid=b.bmanagerid AND m.msalary < 55000
GROUP BY m.mfname, m.mlname, m.msalary, m.mbdate
HAVING count(*)>1;

/* query 7*/
/*Demonstrates NOT NULL*/
SELECT DISTINCT user_guid, `state`, membership_type
FROM users
WHERE country="US" AND state IS NOT NULL and membership_type IS NOT NULL
ORDER BY membership_type DESC, state ASC

/*query 8*/
SELECT DISTINCT country 
FROM users 
WHERE country!='US';
non_us_countries.csv('non_us_countries.csv')

/*query 9*/
/*Demonstrates file output*/
NC_yearly_after_March_1_2014=%sql SELECT DISTINCT user_guid, state, created_at 
FROM users WHERE membership_type=2 AND state="NC" AND country="US" AND 
created_at>'2014_03_01' ORDER BY created_at DESC;
NC_yearly_after_March_1_2014.csv('NC_yearly_after_March_1_2014.csv')



/*The following demonstrates some simple database creation statements, I have done more complicated versions 
this suffices to show my understanding of the process. I am familiar with 2nd normal, 3rd normal forms, etc. and I can easily read and create relevant STAR charts and other schema graphs.*/
DROP DATABASE IF EXISTS `OAG`;
CREATE DATABASE OAG;
USE OAG;
CREATE TABLE Customer (customer_ID INT, Name VARCHAR(50), Home_Phone VARCHAR(10), Work_Phone VARCHAR(10), DOB DATE, Address VARCHAR(50), Customer_Type VARCHAR(50), Sponsor_ID INT, PRIMARY KEY(customer_ID));
CREATE TABLE Signups (Customer_ID INT, Instance_ID INT, Insurance_Form BOOLEAN, PRIMARY KEY (Customer_ID, Insurance_Form, Instance_ID));

set foreign_key_checks=0;
ALTER TABLE Trip_Instance ADD CONSTRAINT Instance_ID_uq UNIQUE (Instance_ID);
ALTER TABLE inventory ADD FOREIGN KEY (equip_name) REFERENCES equipment(equip_name);


/*An alternate way to create a table*/
CREATE TABLE salestransaction
(   tid   VARCHAR(8)   NOT NULL,
  customerid   CHAR(7)   NOT NULL,
  storeid   VARCHAR(3)   NOT NULL,
  tdate   DATE   NOT NULL,
  PRIMARY KEY (tid),
  FOREIGN KEY (customerid) REFERENCES customer(customerid),
  FOREIGN KEY (storeid) REFERENCES store(storeid) );
