
## Step 1:  Install SFDX and connect to an dev org.

## Step 2: Use your favorite SOQL tool to get a list of accounts.

![](https://raw.githubusercontent.com/kbowerma/brownbag1.2/master/img/img1.png)

good we have some accounts.   Now look for contacts.  
![](https://raw.githubusercontent.com/kbowerma/brownbag1.2/master/img/img2.png)

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


