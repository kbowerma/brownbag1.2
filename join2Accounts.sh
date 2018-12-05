# filename: join2Accounts.sh

echo "Id,AccountId"
awk  -F"," 'NR>1 {print $1}' updateContacts.csv > c.tmp
gshuf -n 99 -r 10accounts.csv | awk  -F"," '{print $2}' > a.tmp
lam c.tmp -s , a.tmp
rm a.tmp
rm c.tmp
