# Narrative
# --------
# Customer database cleanup scenario
#
# Extracted from stzdatawranglertest.ring, block #24.
#ERR exit 1: Initial customer database analysis:

load "../../stzBase.ring"


pr()

# Realistic customer data with common issues
aCustomerDB = [
    ["  John Smith  ", "john.smith@email.com", "555-1234", "New York", "NY", "10001", "2020-01-15"],
    ["mary johnson", "MARY@COMPANY.COM", "(555) 567-8901", "los angeles", "ca", "90210", "2019-03-22"],
    ["", "bob.wilson@email.com", "555.234.5678", "Chicago", "IL", "", ""],  # Missing name and date
    ["Alice Brown", "alice@email", "5551234567", "Houston", "TX", "77001", "2021-06-10"],  # Invalid email
    ["John Smith", "john.smith@email.com", "555-1234", "New York", "NY", "10001", "2020-01-15"],  # Duplicate
    ["Tom Davis", "tom@email.com", "555-999-0000", "Phoenix", "AZ", "85001", "2022-12-01"],
    ["SARAH CONNOR", "sarah.connor@email.com", "NULL", "Dallas", "TX", "75201", "2020-08-30"]  # Missing phone
]

aCustomerHeaders = ["Name", "Email", "Phone", "City", "State", "ZIP", "JoinDate"]

o1 = new stzDataWrangler(aCustomerDB, aCustomerHeaders)

? "Initial customer database analysis:"
o1.ShowReport()

? ""
? "Executing comprehensive cleanup..."
aCustomerResult = o1.ExecutePlan("clean", TRUE)

? ""
? "Final cleaned data sample:"
aCleanedCustomers = o1.GetData()
for i = 1 to min([5, len(aCleanedCustomers)])
    ? "Customer " + i + ":"
    _nCustomerHeadersLen_ = ring_len(aCustomerHeaders)
    for j = 1 to _nCustomerHeadersLen_
        ? "• " + aCustomerHeaders[j] + ": " + aCleanedCustomers[i][j]
    next
    ? ""
next

#-->
'
Initial customer database analysis:
╭───────────────────────╮
│ DATA WRANGLING REPORT │
╰───────────────────────╯
• Structure: table
• Dimensions: 7 rows × 7 columns
• Issues Found: 0
• Transformations: 1

🔄 TRANSFORMATIONS APPLIED:
╰─> Data loaded: {Structure: table}

Executing comprehensive cleanup...
• Executing Plan: Basic Data Cleanup
• Remove duplicates, handle missing values, normalize formats

❌ Fill or remove missing values...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Clean whitespace from text...
╰─> Cleaned 1 text values

❌ Standardize text case...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Remove duplicate rows...
╰─> Removed 1 duplicate rows

( Plan execution completed in 0.05 second(s): 2 successful, 2 errors )

Final cleaned data sample:
Customer 1:
• Name: John Smith
• Email: john.smith@email.com
• Phone: 555-1234
• City: New York
• State: NY
• ZIP: 10001
• JoinDate: 2020-01-15

Customer 2:
• Name: mary johnson
• Email: MARY@COMPANY.COM
• Phone: (555) 567-8901
• City: los angeles
• State: ca
• ZIP: 90210
• JoinDate: 2019-03-22

Customer 3:
• Name: 
• Email: bob.wilson@email.com
• Phone: 555.234.5678
• City: Chicago
• State: IL
• ZIP: 
• JoinDate: 

Customer 4:
• Name: Alice Brown
• Email: alice@email
• Phone: 5551234567
• City: Houston
• State: TX
• ZIP: 77001
• JoinDate: 2021-06-10

Customer 5:
• Name: Tom Davis
• Email: tom@email.com
• Phone: 555-999-0000
• City: Phoenix
• State: AZ
• ZIP: 85001
• JoinDate: 2022-12-01
'

pf()
# Executed in 0.07 second(s) in Ring 1.22
