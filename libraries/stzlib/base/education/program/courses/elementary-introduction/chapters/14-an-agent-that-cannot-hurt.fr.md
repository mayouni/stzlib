# Un agent qui ne peut pas nuire

*Introduction élémentaire · Chapitre 14 · Compétences GO-01 « Que couvre mon agent, et que peut-on annuler ? », GO-02 « Qui a le droit de rendre cela réel ? » et GO-03 « Qu'aurait-il fait ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un agent est un programme qui agit de lui-même. Softanza vous laisse en construire un sans danger, parce que
la sécurité n'est pas dans l'agent : elle est dans le monde qui l'entoure. Une cour juge la déclaration, une
porte se dresse entre chaque proposition et chaque effet, et une salle de répétition reçoit l'action avant
la réalité.

## 1. Déclarer un agent, et laisser la cour le juger

Un agent est un fichier texte. Il doit dire ce qu'il couvre et quelle classe d'actes il accomplit, sinon il
n'est jamais planifié.

```ring
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
oDecl = StzAgentDeclarationQ(cPia)
? oDecl.IsValid()
#--> TRUE
? oDecl.ReversibilityClass()
#--> reversible
```

## 2. La cour refuse ce qui ne dit rien de sa portée

```ring
oBad = StzAgentDeclarationQ( StzReplace(cPia, "coverage: checks the kitchen stock every morning and notes what is low" + char(10), "") )
? oBad.IsValid()
#--> FALSE
? StzLeft( oBad.CiteFindings(), 25 )
#--> [pia-coverage @ coverage]
```

## 3. Proposer, jamais valider : la forme d'un système sûr

Un modèle de langage peut proposer. Reliez-le directement à un effet, et le graphe du système n'est pas
sain ; la violation dit pourquoi.

```ring
oGBad = new stzAgentGraph("mailer-bad")
oGBad.AddLLMActor("writer")
oGBad.AddEffect("send")
oGBad.Proposes("writer", "send")
? oGBad.IsSound()
#--> FALSE
? oGBad.Violations()[1][:message]
#--> effect 'send' has no guardian edge into it -- every effect passes a pi-gate
```

## 4. La forme gouvernée

Une porte entre la proposition et l'effet, et une trace après lui.

```ring
oGOk = new stzAgentGraph("mailer")
oGOk.AddLLMActor("writer")
oGOk.AddGuardian("gate")
oGOk.AddEffect("send")
oGOk.AddTraceSink("audit")
oGOk.Proposes("writer", "gate")
oGOk.Guards("gate", "send")
oGOk.Feeds("gate", "send")
oGOk.Traces("send", "audit")
? oGOk.IsSound()
#--> TRUE
```

## 5. Répéter dans un monde sûr

Donnez un atelier à l'agent, et tout ce qu'il écrit y atterrit. Le disque ne bouge pas ; la seule chose qui
en sort est un plan.

```ring
oAg = oDecl.ToAgent()
oAg.GiveWorkbench()
cHere = StzReplace(currentdir(), char(92), "/")
cNote = cHere + "/t_edu_note_" + ProcessId() + ".txt"
oAg.WorkbenchQ().WriteFile(cNote, "stock is low")
? fexists(cNote)
#--> FALSE
? oAg.WorkbenchQ().ContentOf(cNote)
#--> stock is low
oPlan = oAg.GenerateUpdatePlan()
? oPlan.NumberOfOperations()
#--> 1
```

## 6. Une IA ne peut pas valider le plan

```ring
oPlan.SetExecutor( LLMActor("helper") )
aMay = oPlan.MayCommit()
? aMay[1]
#--> FALSE
? aMay[2]
#--> actor 'helper' cannot commit -- it lacks the 'effectful' capability (required by operation 1)
```

## 7. Seul un acteur de validation, dans sa portée, change la réalité

Le proposant est créatif. Le validateur est déterministe, détient la capacité, et peut toucher un dossier et
rien d'autre. Maintenant, et seulement maintenant, le fichier existe.

```ring
oPlan2 = oAg.GenerateUpdatePlan()
oPlan2.SetExecutor( PIActor("committer") )
oScope = new stzCommitScope()
oScope.AllowUnder(cHere)
oPlan2.SetScope(oScope)
aRes = oPlan2.Execute()
? aRes[1][2]
#--> TRUE
? fexists(cNote)
#--> TRUE
remove(cNote)
```

{{exercise:ex-14-01}}

{{exercise:ex-14-02}}

{{exercise:ex-14-03}}

## Récapitulatif

- **Acquis :** vous avez déclaré un agent et fait admettre par la cour, puis refuser son jumeau négligent,
  relié une proposition à travers une porte et vu la forme non saine nommée, et répété une action qui n'a
  jamais touché le disque et qu'une IA n'a pas pu valider.
- **Pourquoi c'est important :** un élève peut construire un agent parce que l'agent ne peut pas nuire. La
  sécurité est dans la cour, la porte et la salle de répétition, pas dans les bonnes intentions de l'élève.
- **La suite :** les instruments qui ont vérifié chaque chapitre de ce cours, entre vos mains.
