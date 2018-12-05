List<Contact> con = new List<Contact>();
for (Contact tmp  : [select id FROM contact where createddate = TODAY ] ) {
    Integer rand = Math.round(Math.random()*100);
    tmp.Title = 'Employee Number '+String.valueof(rand);
    tmp.Phone = '';
con.add(tmp);
}
Update con;
