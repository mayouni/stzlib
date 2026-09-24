cPia = "pia: 1
name: stock-watcher
kind: pi
coverage: checks the kitchen stock every morning and notes what is low
reversibility: reversible
schedule:
  timer: 20
memory:
  - stock level unknown
skills:
  - name: check-stock
    when: always
    does: learn stock level checked
    verify: fact stock level checked
"
oAg = StzAgentDeclarationQ(cPia).ToAgent()
oAg.GiveWorkbench()
oAg.WorkbenchQ().WriteFile("t_ex14_note.txt", "stock is low")
? fexists("t_ex14_note.txt")
? oAg.GenerateUpdatePlan().NumberOfOperations()
