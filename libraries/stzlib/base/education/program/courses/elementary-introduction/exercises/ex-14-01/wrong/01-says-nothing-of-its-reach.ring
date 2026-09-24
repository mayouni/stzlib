# No coverage line: the court refuses it.
cPia = "pia: 1
name: stock-watcher
kind: pi
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
oDecl = StzAgentDeclarationQ(cPia)
? oDecl.IsValid()
