# Writes to the disk itself: the file exists, and no plan was rehearsed.
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
write("t_ex14_real.txt", "stock is low")
? fexists("t_ex14_real.txt")
? oAg.GenerateUpdatePlan().NumberOfOperations()
remove("t_ex14_real.txt")
