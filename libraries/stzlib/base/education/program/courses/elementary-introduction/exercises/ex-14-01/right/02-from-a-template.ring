cPia = "pia: 1
name: NAME
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
oDecl = StzAgentDeclarationQ( StzReplace(cPia, "NAME", "stock-watcher") )
? oDecl.IsValid()
? oDecl.ReversibilityClass()
