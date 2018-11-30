var faker = require('faker');
var  moment = require('moment');
var  fs = require('fs');
var  readline = require('readline');


var departmentPicklist = [ 'Sales' , 'Accounting', 'Warehouse' ];

var rd = readline.createInterface({
    input: fs.createReadStream('todaysSFDCContacts.csv'),
});

//Write a new header file with our new fields Appended to the end.
console.log("Id,FirstName,LastName,MobilePhone,Email,Birthdate,Department");

var lineumber =1;
rd.on('line', function(line) {
    // choose a date in the past starting for 1/1/2001 going back as much as 70 years
    mydate = faker.date.past(70, '2000-01-01');
    formattedBirthDate = moment(mydate).format("YYYY-MM-DD"); 
    rowDepartment = faker.random.arrayElement(departmentPicklist);
    
    if(lineumber > 1 ) {
        output = [line, formattedBirthDate, rowDepartment]
        console.log(output.toString() );
    }

    lineumber++;
});
