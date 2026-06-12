# Narrative
# --------
# Testing data type conversion
#
# Extracted from stzdatawranglertest.ring, block #9.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Mixed data types that need conversion
aMixedData = [
    ["Item1", "123", "true", "2023-01-15"],
    ["Item2", "456.78", "false", "2023-02-20"],
    ["Item3", "789", "yes", "2023-03-10"]
]
aMixedHeaders = ["Name", "Value", "Active", "Date"]

o1 = new stzDataWrangler(aMixedData, aMixedHeaders)

? "BEFORE TYPE CONVERSION:"
aProfile = o1.GetDataProfile()
aTypesSummary = aProfile[:data_types]
_nTypesSummary1Len_ = len(aTypesSummary)
for _iLoopTypesSummary1_ = 1 to _nTypesSummary1Len_
	typeInfo = aTypesSummary[_iLoopTypesSummary1_]
    ? " • " + typeInfo[1] + ": " + o1._JoinList(typeInfo[2], ", ")
next

? ""

# Define conversion rules
aConversionRules = [
    ["Value", "numeric"],
    ["Active", "boolean"]
]

nConverted = o1.ConvertDataTypes(aConversionRules)
? "AFTER TYPE CONVERSION:"
? " • Values converted: " + nConverted
? " • Ddata: " + @@(o1.GetData())

#-->
'
BEFORE TYPE CONVERSION:
 • Name: string
 • Value: string
 • Active: boolean, string
 • Date: date

AFTER TYPE CONVERSION:
 • Values converted: 5
 • Ddata: [ [ "Item1", 123, 1, "2023-01-15" ], [ "Item2", 456.78, "false", "2023-02-20" ], [ "Item3", 789, 1, "2023-03-10" ] ]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
