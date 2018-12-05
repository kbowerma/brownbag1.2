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

