# Wakilin da ba zai iya cutarwa ba

*Gabatarwa ta Farko · Babi na 14 · Fasahohi GO-01 "Me wakilina ya shafa, kuma me za a iya juyawa?", GO-02 "Wa aka yarda ya sa wannan ya zama gaskiya?" da GO-03 "Me da ya yi?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Wakili shiri ne da yake aiki da kansa. Softanza tana barinka ka gina ɗaya lafiya, domin amincin ba a cikin
wakilin yake ba: yana cikin duniyar da ke kewaye da shi. Kotu tana hukunta bayanin, ƙofa tana tsaye tsakanin
kowace shawara da kowane tasiri, kuma ɗakin gwaji yana ɗaukar aikin kafin gaskiya.

## 1. Bayyana wakili, ka bar kotu ta hukunta shi

Wakili fayil na rubutu ne. Dole ne ya faɗi abin da ya shafa da irin aikin da yake yi, in ba haka ba ba za a
taɓa tsara shi ba.

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

## 2. Kotu tana ƙin abin da bai faɗi komai game da iyakarsa ba

```ring
oBad = StzAgentDeclarationQ( StzReplace(cPia, "coverage: checks the kitchen stock every morning and notes what is low" + char(10), "") )
? oBad.IsValid()
#--> FALSE
? StzLeft( oBad.CiteFindings(), 25 )
#--> [pia-coverage @ coverage]
```

## 3. Ba da shawara, kada ka aiwatar: siffar tsari mai aminci

Samfurin harshe na iya ba da shawara. Haɗa shi kai tsaye da tasiri, kuma zanen tsarin ba shi da inganci;
keta ta faɗi dalili.

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

## 4. Siffar da ake mulka

Ƙofa tsakanin shawarar da tasirin, da bin sawu bayansa.

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

## 5. Yi gwaji a duniya mai aminci

Ba wa wakilin wurin aiki, kuma duk abin da ya rubuta yana sauka a can. Faifan ba ya motsawa; abin da ke
fitowa kawai tsari ne.

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

## 6. AI ba za ta iya aiwatar da tsarin ba

```ring
oPlan.SetExecutor( LLMActor("helper") )
aMay = oPlan.MayCommit()
? aMay[1]
#--> FALSE
? aMay[2]
#--> actor 'helper' cannot commit -- it lacks the 'effectful' capability (required by operation 1)
```

## 7. Mai aiwatarwa kaɗai, a cikin iyakarsa, yake canza gaskiya

Mai ba da shawara mai ƙirƙira ne. Mai aiwatarwa tabbatacce ne, yana riƙe da iko, kuma zai iya taɓa babban
fayil ɗaya kawai. Yanzu, kuma yanzu kawai, fayil ɗin yana nan.

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

## Taƙaitawa

- **Abin da ka cimma:** ka bayyana wakili kotu ta karɓe shi ta ƙi tagwayensa mara kula, ka haɗa shawara ta
  ƙofa ka ga an sa wa siffar mara inganci suna, ka yi gwajin aikin da bai taɓa faifan ba kuma AI ba ta iya
  aiwatar da shi ba.
- **Me ya sa yake da muhimmanci:** ɗalibi zai iya gina wakili domin wakilin ba zai iya cutarwa ba. Amincin
  yana cikin kotu, ƙofa da ɗakin gwaji, ba a cikin kyakkyawar niyyar ɗalibin ba.
- **Abin da ke tafe:** kayan aikin da suka duba kowane babi na wannan darasin, a hannunka.
