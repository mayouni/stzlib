# Narrative
# --------
# Testing export to different Softanza classes
#
# Extracted from stzdatawranglertest.ring, block #15.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"


pr()

# Prepare clean dataset for export testing
aCleanData = [
    ["Alice", 25, 55000],
    ["Bob", 30, 60000],
    ["Carol", 28, 58000],
    ["David", 35, 70000]
]
aCleanHeaders = ["Name", "Age", "Salary"]

o1 = new stzDataWrangler(aCleanData, aCleanHeaders)

? BoxRound("EXPORT FOR stzDataSet")

aDataSetExport = o1.ExportForStzDataSet()
? "• Class name: " + StzDataSetQ(aDataSetExport).ClassName()
? "• Exported data structure: " + len(aDataSetExport) + " rows"
? "• Sample data:"
for i = 1 to min([3, len(aDataSetExport)])
    ? " ─ Row " + i + ": " + o1._JoinList(aDataSetExport[i], ", ")
next
#-->
'
╭───────────────────────╮
│ EXPORT FOR stzDataSet │
╰───────────────────────╯
• Class name: stzdataset
• Exported data structure: 4 rows
• Sample data:
 ─ Row 1: Alice, 25, 55000
 ─ Row 2: Bob, 30, 60000
 ─ Row 3: Carol, 28, 58000
'

#---

? ""
? BoxRound("EXPORT FOR stzTable")
aTableExport = o1.ExportForStzTable()
? "• Headers: " + o1._JoinList(aTableExport[1], ", ")
? "• Data rows: " + len(aTableExport[2])
#-->
'
╭─────────────────────╮
│ EXPORT FOR stzTable │
╰─────────────────────╯
• Headers: Name, Age, Salary
• Data rows: 4
'

#---

? ""
? BoxRound("EXPORT FOR stzMatrix")
aMatrixExport = o1.ExportForStzMatrix()

? "• Class name: " + StzMatrixQ(aDataSetExport).ClassName()
? "• Matrix dimensions: " + len(aMatrixExport) + " × " + len(aMatrixExport[1])
? "• Sample numeric data:"

for i = 1 to min([3, len(aMatrixExport)])

	if i = 1
		cSepLeft = "╭"
		cSepRight = "╮"
	but i = 2
		cSepLeft = "│"
		cSepRight = "│"
	but i = 3
		cSepLeft = "╰"
		cSepRight = "╯"
	ok

    ? ' ' + cSepLeft + " " + o1._JoinList(aMatrixExport[i], ", ") + " " + cSepRight

next

#-->
'
╭──────────────────────╮
│ EXPORT FOR stzMatrix │
╰──────────────────────╯
• Class name: stzmatrix
• Matrix dimensions: 4 × 3
• Sample numeric data:
 ╭ 0, 25, 55000 ╮
 │ 0, 30, 60000 │
 ╰ 0, 28, 58000 ╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=======================================#
#  TEST SECTION 7: CONVENIENCE METHODS  #
#=======================================#
