# Narrative
# --------
# #TODO Make a narration
#
# Extracted from stztabletest.ring, block #227.
#ERR Error (R14) : Calling Method without definition: fromcsv

load "../../stzBase.ring"


pr()

cCSVTeam = 'Employee;Role;Task;Productivity
Sara;Developer;["Coding", "Debugging"];8.5
Mike;Manager;["Planning", "Review"];7.2
Lena;Designer;["UI", "Prototyping"];9.0
Omar;Developer;["Coding", "Testing"];8.0
Tara;Manager;["Planning", "Coordination"];7.8
Alex;Designer;["UI", "Animation"];8.7'

o1 = new stzTable([])
o1.FromCSV(cCSVTeam)

o1.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬───────────┬────────────────────────────────┬──────────────╮
# │ # │    Employee     │   Role    │             Task              │ Productivity │
# ├───┼─────────────────┼───────────┼────────────────────────────────┼──────────────┤
# │ 1 │ Sara            │ Developer │ [ "Coding", "Debugging" ]      │         8.50 │
# │ 2 │ Mike            │ Manager   │ [ "Planning", "Review" ]       │         7.20 │
# │ 3 │ Lena            │ Designer  │ [ "UI", "Prototyping" ]        │            9 │
# │ 4 │ Omar            │ Developer │ [ "Coding", "Testing" ]        │            8 │
# │ 5 │ Tara            │ Manager   │ [ "Planning", "Coordination" ] │         7.80 │
# │ 6 │ Alex            │ Designer  │ [ "UI", "Animation" ]          │         8.70 │
# ╰───┴─────────────────┴───────────┴────────────────────────────────┴──────────────╯


o1.GroupBy(:Task)
o1.Show()
#-->
# ╭──────────────┬──────────┬───────────┬──────────────╮
# │    Task      │ Employee │   Role    │ Productivity │
# ├──────────────┼──────────┼───────────┼──────────────┤
# │ Coding       │ Sara     │ Developer │         8.50 │
# │ Coding       │ Omar     │ Developer │            8 │
# │ Debugging    │ Sara     │ Developer │         8.50 │
# │ Planning     │ Mike     │ Manager   │         7.20 │
# │ Planning     │ Tara     │ Manager   │         7.80 │
# │ Review       │ Mike     │ Manager   │         7.20 │
# │ UI           │ Lena     │ Designer  │            9 │
# │ UI           │ Alex     │ Designer  │         8.70 │
# │ Prototyping  │ Lena     │ Designer  │            9 │
# │ Testing      │ Omar     │ Developer │            8 │
# │ Coordination │ Tara     │ Manager   │         7.80 │
# │ Animation    │ Alex     │ Designer  │         8.70 │
# ╰──────────────┴──────────┴───────────┴──────────────╯

# Turining the table into a pivot table

oPivot = o1.ToStzPivotTable()

# Analyzing Productivity in avaerage by task and role

oPivot {

	Analyze([ :Productivity ], :In = :Average)
	By([ :Task ], :And = [ :Role ])

	Show()
}
#-->
# ╭──────────────┬─────────────────────────────────┬─────────╮
# │              │              Role               │         │
# │              │───────────┬──────────┬──────────│         │
# │     Task     │ Developer │ Manager  │ Designer │ AVERAGE │
# ├──────────────┼───────────┼──────────┼──────────┼─────────┤
# │ Coding       │         8 │          │          │       8 │
# │ Debugging    │      8.50 │          │          │    8.50 │
# │ Planning     │           │     7.50 │          │    7.50 │
# │ Review       │           │     7.20 │          │    7.20 │
# │ UI           │           │          │     8.85 │    8.85 │
# │ Prototyping  │           │          │        9 │       9 │
# │ Testing      │         8 │          │          │       8 │
# │ Coordination │           │     7.80 │          │    7.80 │
# │ Animation    │           │          │     8.70 │    8.70 │
# ╰──────────────┴───────────┴──────────┴──────────┴─────────╯
#        AVERAGE │      8.17 │     7.50 │     8.85 │    8.17  

# Pivot Table: Task Distribution

oPivot {

  Analyze([ :Employee ], :COUNT)

  SetRowsBy([ :Task ])
  SetColsBy([ :Role ])

  Show()
}
#-->
# ╭──────────────┬─────────────────────────────────┬───────╮
# │              │              Role               │       │
# │              │───────────┬──────────┬──────────│       │
# │     Task     │ Developer │ Manager  │ Designer │ COUNT │
# ├──────────────┼───────────┼──────────┼──────────┼───────┤
# │ Coding       │         1 │          │          │     1 │
# │ Debugging    │         1 │          │          │     1 │
# │ Planning     │           │        2 │          │     2 │
# │ Review       │           │        1 │          │     1 │
# │ UI           │           │          │        2 │     2 │
# │ Prototyping  │           │          │        1 │     1 │
# │ Testing      │         1 │          │          │     1 │
# │ Coordination │           │        1 │          │     1 │
# │ Animation    │           │          │        1 │     1 │
# ╰──────────────┴───────────┴──────────┴──────────┴───────╯
#         COUNT │         3 │        3 │        3 │     9  

#TODO: Check why Coding/Developer is not returning 2

# High-productivity tasks

o1.FilterW('@(:Productivity) > 8')
o1.Show()

# Critical tasks
CrticalTasks = ["Coding", "Debugging", "Planning"]
o1.AddCalculatedColumn(:Critical, ' @IF( Q(@(:Task)).ContainsOneOfThese(CrticalTasks), "YES", "NO" )')
o1.Show()


o1.ToStzPivotTable() {
  Analyze([ :Productivity ], :Average)
  InRowsPut([ :Task ])
  InColsPut([ :Role])
  Show()
}

pf()
# Executed in 1.06 second(s) in Ring 1.22
