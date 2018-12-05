
## Step 1:  Install SFDX and connect to an dev org.

## Step 2: Use your favorite SOQL tool to get a list of accounts.

![](./img/img1.png) 

good we have some accounts.   Now look for contacts.  
![](./img/img2.png) 

Oh Shoot it looks like we have some work to do.  Lets start with a NodeJS script to randomly make some names.  Lets assume you have node js installed and you are somewhat familar with the package manager called npm.

We are going to install a syntetehic data generator called [fakerJS](https://github.com/marak/Faker.js/) and a date library that will help us with date time format called moment.  But first lets stub out a package.json file so we can track our dependcies, and then install faker and moment

```
npm init
npm install faker moment --save
```

Now lets great a file called newNames.js, and include our 2 libraries:

```javascript
var faker = require('faker');
var moment = require('moment');
```
and add the following line:
```javascript
console.log("A fake name is ", faker.name.findName() );
```
and run the file with node newNames.js.  You should see something like this. 

![](./img/img3.png) 

Ok now we are cooking with gas,  Lets add a couple more fields and run it in a loop.   Replace the console.log with this block

```javascript
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
```
## Command 3: generate a file with 99 faker contacts
Now we can run it and redirect the output to a csv file:

```node newNames.js > newcontacts.csv```

and we should get something like this, note there are no spaces after the comma in the header.

![](img/img4.png)

Now we have a sample file,  lets use sfdx to import the new synthetic contacts.  But before we do that lets use sfdx to query and show our contacts are nearly empty.   Note that 'wave' is the alias for the user and my org.

```
sfdx  force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email from contact" -u wave
```
![](img/img5.png)

Ok good, I am in the right org and just 4 contacts.  Now lets run the sfdx command to import the data.
## Command 4: insert the 99 contacts

 ```
 sfdx force:data:bulk:upsert -f newcontacts.csv -s contact -i Id -w 2 -u wave
 ```
 and you should see something like this: 

 ![](img/img6.png)

 We can even use sfdx to see if the records are really there.   Just use the same line from above.  ```sfdx  force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email from contact" -u wave``` 

 ![](img/img7.png)

 We see the 99 new contact there so lets modify this query to just get the contacts we created today and  slightly so we can export it to csv.  We just need to add ```-r csv``` to the end to format the output to csv.
 
 ## Command 5: get the ids of the 99 new contacts
 ```
 sfdx force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email from contact where createddate=TODAY" -u wave  -r csv  > todaysSFDCContacts.csv 
 ```

Notice that query also gives us the Ids which we will need later.  So lets do the same thing to the Accounts so we can assgin the Contacts to Account.   First lets just get the accounts and throw the names in there for fun.  

## Command 6: get the accounts and stow it away
```
sfdx  force:data:soql:query -q "select id, name from account" -u wave -r csv > accounts.csv
```

Before we assign these contact to accounts lets use faker again add a random picklist value (Department: Sales, Accounting, or Warehouse)  and a date, specificly birthdate.   Lets start a new file called ```assignFields.js``` we need to add a few more libraries to open read from a file.  Also lets create an array for the department that we will randomly select.

```
var faker = require('faker');
var  moment = require('moment');
var  fs = require('fs');
var  readline = require('readline');

var department = [ 'Sales' , 'Accounting' , 'Warehouse' ];
```

Next we add logic to create a file stream and read from our contact file.
```
var rd = readline.createInterface({
    input: fs.createReadStream('todaysSFDCContacts.csv'),
});
```
The line above creates file stream from the contact file ('todaysSFDCContacts.csv') we pulled from Salesforce.  We are going to loop through this file and write each line to the console but will add our two new fields: Deparment and birthdate.  We already have a column header row on the input file but we are going to skip it and just write a new column header before we loop through.

```
console.log("Id,FirstName,LastName,MobilePhone,Email,Birthdate,Department");
```
Relasticly we are going to do an update so we only need the Id and the new fields but for simplitisty we will leave the old row as is.  Here is the iterator block that starts by initilizeing a line counter. 

```javascript
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
```
The 'on' method of the readline library is a built in iterator and takes a variable for the iterator name ```line```  and then the call back.  If the linenumber is greater than 1 (quick way to skip the old header) the output array is written to the consloe.  We can redirect the console to a output file that we then send to Salesforce.

## Command 7: Run the faker script to generate two new fields to update out contacts
```
node assignFields.js  > updateContacts.csv
```
## Command 8: update saleforce with the new fields
```
sfdx force:data:bulk:upsert -f updateContacts.csv -s Contact -i Id -w 2 -u wave
```
and we can use sfdx to show the new results:
```
sfdx  force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email, department, birthdate from contact" -u wave
```
 ![](img/img8.png)

Yup!   Looks good.

Next I want to assign these 99 contacts to 1 of 10 accounts so I will randomly select 10 accounts but I suspect that my accounts.csv file has order to it (i.e. persona accounts first, alphapetical, ordered by state...) so I so not want to simply take the first 10 with ``` head -10 accounts > 10accounts.csv```, instead I want to take 1o randmom rows.   I can do this with ```shuf``` (aliased from gshuf)  __This is very important,   When ever you take a sample of a data file, always make sure it is random__.     Just for fun I am going to add an index number to my  accounts so you can see that the row numbers are really random.   Here is what it look like before.
 ![](img/img9.png)
 And after I run the following command and redirect the output to a new file called ___accountsWlines.csv___
 
 ## Command 9: add line number to accounts (just for fun) 

 ```awk '{print NR","$0}' accounts.csv > indexedAccounts.csv```

![](img/img10.png)

Now lets get a real random sample of 10 accounts.  
### Command 10: get a random sample of 10 accounts
```gshuf -n 10 indexedAccounts.csv  > 10accounts.csv```

You can see by the row number in front of the id that we truely have a random grab of 10 accounts from this file.

![](img/img11.png)

Now we have a file ( _10accounts.csv_ ) with 10 accounts and we have another file with 100 contacts (_updateContacts.csv_).   Both of these files have the Salesforce Ids but they have a different length.   Luckliy we can use shuf again with a repeat switch to generate a account file with 100 rows.  Let write alittle script that will take 100 contact ids and account ids and laminate them together.

Create a new file called ___join2Accounts.sh___ and paste in the following:

```bash
echo "Id,AccountId"
awk  -F"," 'NR>1 {print $1}' updateContacts.csv > c.tmp
gshuf -n 99 -r 10accounts.csv | awk  -F"," '{print $2}' > a.tmp
lam c.tmp -s , a.tmp
rm a.tmp c.tmp
```

and run the script and redirct to _contactWithAccountsUpdate.csv_

## Command 11: generate a laminated file of 99 contacts with 1 of the 10 accounts
```
sh join2Accounts.sh > contactWithAccountsUpdate.csv
```

Before we update the contacts lets run a quick check to see that our contacts don't belong to any accounts:

```
sfdx force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email, accountId from contact " -u wave
```
and we should see the final column is __null__, so lets go ahead and update the contacts with sfdx.

## Command 12: update the contacts with the account ids
```
sfdx force:data:bulk:upsert -f contactWithAccountsUpdate.csv -s contact -i Id -w 2 -u wave
```

and show:

```
sfdx force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email, accountId from contact " -u wave
```


and now from the begining lets automate the whole thing (the wrapper script below is in doEverything.sh)

```bash
#empty out the contacts
echo "Command 1: empty out the contacts"
sfdx force:apex:execute -f emptyAccounts.apex -u wave
# run a query to show that sfdc is virtualy empty
echo "Command 2: show the org is empty"
sfdx force:data:soql:query -q "select count(id) from contact " -u wave
# generate a file with 99 faker contacts
echo "Command 3: generate a file with 99 faker contacts"
node newNames.js > newcontacts.csv
# Load these 99 contacts to salesforce
echo "Command 4: insert the 99 contacts"
sfdx force:data:bulk:upsert -f newcontacts.csv -s contact -i Id -w 2 -u wave
# get the ids of the newly created records and write them to a file
echo "Command 5: get the ids of the 99 new contacts"
sfdx force:data:soql:query -q "select id, firstname, lastname, MobilePhone, email from contact where createddate=TODAY" -u wave  -r csv  > todaysSFDCContacts.csv 
# get the accounts for for future updates to the contacts
echo "Command 6: get the accounts and stow it away"
sfdx  force:data:soql:query -q "select id, name from account" -u wave -r csv > accounts.csv
# generate a new file with updates to contacts
echo "Command 7: Run the faker script to generate two new fields to update out contacts"
node assignFields.js  > updateContacts.csv
# update salesforce with birthdate and department
echo "Command 8: update saleforce with the new fields"
sfdx force:data:bulk:upsert -f updateContacts.csv -s Contact -i Id -w 2 -u wave
# add line number to accounts
echo "Command 9: add line number to accounts (just for fun) "
awk '{print NR","$0}' accounts.csv > indexedAccounts.csv
# get 10 account sample
echo "Command 10: get a random sample of 10 accounts"
gshuf -n 10 indexedAccounts.csv  > 10accounts.csv
# laminate account ids to contact.
echo "Command 11:  generate a laminated file of 99 contacts with 1 of the 10 accounts "
sh join2Accounts.sh > contactWithAccountsUpdate.csv
# update contact.accountid
echo "Command 12: update the contacts with the account ids"
sfdx force:data:bulk:upsert -f contactWithAccountsUpdate.csv -s contact -i Id -w 2 -u wave



```




---
 




## Other Unix goodiess
1. head: select the top x lines of a file
1. gshuf - shuffles the rows of a file,  good to be ued with head to get a random sampling