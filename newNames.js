
var faker = require('faker');
var moment = require('moment');

var firstname, lastname, MobilePhone, email; 



/* SOQL Query:
 * select id, firstname, lastname, MobilePhone, email from contact
 */ 

//First we need to print the header 
console.log('FirstName,LastName,MobilePhone,email')

//Then Loop through and create the rows.
for ( i=0; i<99; i++ ){
    firstname = faker.name.firstName();
    lastname = faker.name.lastName();
    MobilePhone = faker.phone.phoneNumberFormat();
    email = faker.internet.email( firstname, lastname,"example.com");
    output = [firstname, lastname, MobilePhone, email];
    console.log(output.toString());
};
