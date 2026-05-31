# Narrative
# --------
# Ring vs Softanza file read()
#
# Extracted from stztabletest.ring, block #216.

load "../../../stzBase.ring"

pr()

# The file "tabdata.csv" contains this:

'tree_id;block_id;created_at;tree_dbh;alive
180683;348711;08/27/2015;3;Alive
200540;315986;09/03/2015;21;Alive
204026;218365;09/05/2015;3;Dead
204337;217969;09/05/2015;10;Alive
189565;223043;08/30/2015;21;Alive
190422;106099;08/30/2015;11;Dead
190426;106099;08/30/2015;11;Alive
208649;103940;09/07/2015;9;Alive
209610;407443;09/08/2015;6;Alive
180683;348711;08/27/2015;3;Alive
'

# Let's ceate an empty stzTable object

o1 = new stzTable([])

# The goal is to import the external CSV file inside the table
# To do that, and since stzTable deal only with CSV string and
# has no access to external files, we need to manually read the
# content of the file and store it in a string variable.

# Let's do it first using Ring standart read() function

str = read("tabdata.csv") # EOLs (End-Of-File chars are platform specific)
? o1.FromCSV(str)		 # And hence lines internal split is not correct

o1.Show()
# You will notice that header row is misaligned due to hidden EOL issues
# Each data row also includes extra newlines
#-->                        
'                           
╭─────────┬──────────┬────────────┬──────────┬────────╮
│ Tree_id │ Block_id │ Created_at │ Tree_dbh │ Alive
 │
├─────────┼──────────┼────────────┼──────────┼────────┤
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive
 │
│  200540 │   315986 │ 09/03/2015 │       21 │ Alive
 │
│  204026 │   218365 │ 09/05/2015 │        3 │ Dead
  │
│  204337 │   217969 │ 09/05/2015 │       10 │ Alive
 │
│  189565 │   223043 │ 08/30/2015 │       21 │ Alive
 │
│  190422 │   106099 │ 08/30/2015 │       11 │ Dead
  │
│  190426 │   106099 │ 08/30/2015 │       11 │ Alive
 │
│  208649 │   103940 │ 09/07/2015 │        9 │ Alive
 │
│  209610 │   407443 │ 09/08/2015 │        6 │ Alive
 │
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive  │
╰─────────┴──────────┴────────────┴──────────┴────────╯
'

# Solved automatically Using Softanza stzFile object

oFile = new stzFileXT("tabdata.csv", :ReadOnly)  # stzFile handles EOLs uniformly
str = oFile.Content()   #TODO #ERR                       	 # retrieves clean text content

o1.FromCSV(str) # correctly parsed and formatted

o1.Show()
# Output is clean, compact and platform-independent
#-->
'
╭─────────┬──────────┬────────────┬──────────┬───────╮
│ Tree_id │ Block_id │ Created_at │ Tree_dbh │ Alive │
├─────────┼──────────┼────────────┼──────────┼───────┤
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive │
│  200540 │   315986 │ 09/03/2015 │       21 │ Alive │
│  204026 │   218365 │ 09/05/2015 │        3 │ Dead  │
│  204337 │   217969 │ 09/05/2015 │       10 │ Alive │
│  189565 │   223043 │ 08/30/2015 │       21 │ Alive │
│  190422 │   106099 │ 08/30/2015 │       11 │ Dead  │
│  190426 │   106099 │ 08/30/2015 │       11 │ Alive │
│  208649 │   103940 │ 09/07/2015 │        9 │ Alive │
│  209610 │   407443 │ 09/08/2015 │        6 │ Alive │
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive │
╰─────────┴──────────┴────────────┴──────────┴───────╯
'

pf()
#--> Executed in 0.88 second(s) in Ring 1.22
