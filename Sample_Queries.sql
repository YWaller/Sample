use OAG_CLUB;

/*query 1*/
select  e.customer_ID as 'Sponsor ID', e.name, e.address, e.home_phone, e.customer_type 
from customer c join customer e on c.Sponsor_ID = e.customer_ID 
group by e.customer_ID 
having count(e.customer_ID >= 2);

/*query 2*/
SELECT DISTINCT C.customer_ID, C.`Name`, C.Home_Phone, C.Work_Phone, I.Item_Number, I.`condition`, I.equip_name
FROM customer C
INNER JOIN rental_agreement R ON C.customer_ID = R.customer_ID
INNER JOIN rental_detail E ON E.agreement_num = R.agreement_number
INNER JOIN inventory I ON E.Item_number = I.item_Number
WHERE E.real_return IS NULL AND (E.expected_return) <= Now() - 2;

/*query 3*/
SELECT DISTINCT Employee_Name
FROM OAG_Employee
JOIN `position` on OAG_employee.Position_ID = `position`.position_id
WHERE `position`.position_descr = 'Project Coordinator' OR `position`.position_ID = 5
HAVING COUNT(oag_employee.employee_Name) = 2;

/*query 4*/
SELECT employee_ID, employee_name from OAG_employee
WHERE employee_id not in (select employee_leader_id from trip_instance);

/*query 5*/
select customer.name, customer.address from rental_agreement 
join customer on rental_agreement.customer_ID = customer.customer_ID 
group by rental_agreement.customer_ID 
having count(rental_agreement.customer_ID) >= 2;

/*query 6*/
select (Employee_assistant_ID) from trip_instance
having count(employee_assistant_id) > 1;

/*query 7*/
select name from customer
where customer_id not in (select customer_id from signups);

/*query 8*/
select name from customer
where customer_id not in (select customer_id from rental_agreement);

/*query 9*/
select count(equip_name) as 'total number of equipment types' from equipment;

/*query 10*/
select count(customer_ID) as 'Total Number of Signups', instance_ID from signups group by Instance_ID;

/*query 11*/
select rental_detail.item_number, count(rental_detail.item_number) as 'Times an item has been checked out' 
from rental_detail join inventory on inventory.item_number = rental_detail.item_number
group by rental_detail.item_number;

/*query 12*/
select equip_name as 'item type' , count(equip_name) as 'item quantity' from inventory
group by equip_name

