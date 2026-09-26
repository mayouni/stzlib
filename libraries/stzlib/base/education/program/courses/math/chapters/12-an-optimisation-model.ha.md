# Samfurin inganta

*Lissafi · Babi na 12 · Ƙwarewa FO-04: "Zan iya faɗin abin da nake so in bar injin ya yanke yadda?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Shawara tana da sassa uku: lambobin da za ka iya zaɓa, abin da kake son mafi yawa, da abin da dole ka riƙe
ƙasa. An rubuta su tare sun zama samfuri, kuma ana warware samfuri, ba a lissafa shi: injin yana samun mafi
kyawun zaɓi ya faɗi yadda ya samu shi. Wannan babin yana rubuta samfuri ɗaya sau biyu, a matsayin abu da a
matsayin jumla, ya duba cewa duka biyun samfuri ɗaya ne, ya karanta mafi kyawun shiri ya duba shi da hannu,
kuma ya haɗu da ƙi biyu da samfuri yake yi.

## 1. Samfurin a matsayin abu

Lambobi biyu da za a zaɓa, x har zuwa arba'in da y cikakken lamba; ƙara uku x ƙari biyu y zuwa mafi girma;
riƙe jimla biyu ƙasa da iyakokinsu. Nemi injin ya warware shi.

```ring
oM = new stzOptimModel()
oM.Vars([ :x = [ 0, 40 ], :y = [ 0, :integer ] ])
oM.Maximize("3*x + 2*y")
oM.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
oM.SolveWith(:auto)
? oM.StatusWord()
#--> optimal
? oM.Objective()
#--> 130
? @@( oM.Solution() )
#--> [ [ "x", 30 ], [ "y", 20 ] ]
```

## 2. Injin yana ambatar kansa

Samfurin yana faɗin wane inji ya gudana da abin da ya samu. Akwai inji ɗaya da aka gina yau, kuma jumlar ta
faɗi haka maimakon riya cewa akwai biyu.

```ring
? oM.Why()
#--> Objective 130 at x = 30, y = 20
? oM.Engine()
#--> engine floor (Zig simplex + branch-and-bound)
```

## 3. Mafi kyawun shiri, an duba da hannu

Mafita magana ce. Samfurin yana duba kowane ƙuntatawa a kanta ya bayar da rahoton keta, kuma za ka iya duba
jimla biyun da manufar da kanka.

```ring
? @@( oM.Violations() )
#--> [ ]
? 30 + 20 <= 50
#--> 1
? 2 * 30 + 20 <= 80
#--> 1
? 3 * 30 + 2 * 20
#--> 130
```

## 4. Samfuri ɗaya a matsayin jumla

Faɗi samfurin a kalmomi, ɗakin karatu zai gina abu ɗaya, ta hanyar kira uku ɗaya. Fuska biyu, samfuri ɗaya:
sa hannun tsarinsu na zahiri daidai suke, wanda ake duba maimakon zato, saboda samfurai biyu marasa daidai
za su iya yarda a kan lamba.

```ring
oS = StzOptimNaturally("
        maximize 3*x + 2*y
        where x is between 0 and 40
        and y is a whole number at least 0
        keeping x + y under 50
        and keeping 2*x + y under 80
     ")
? oS.ASTSignature() = oM.ASTSignature()
#--> 1
oS.Solve()
? oS.Objective()
#--> 130
```

## 5. Samfurin, an sake faɗa

Nemi samfurin ya bayyana kansa, ya faɗi manufa, ƙuntatawa da iyakokin da yake riƙe.

```ring
? oM.Describe()
#--> max 3*x + 2*y
```

## 6. Shirin samarwa

Kujeru suna samun talatin suna ɗaukar awa biyu; teburori suna samun arba'in da biyar suna ɗaukar biyar; awa
ɗari biyu da hamsin kuma a mafi yawa sittin na kowanne. Mafi kyawun shiri kujeru sittin da teburori ashirin
da shida, kuma neman cikakkun lambobi yana sa injin ya rassa sau ɗaya.

```ring
oN = new stzOptimModel()
oN.Vars([ :chairs = [ 0, :integer ], :tables = [ 0, :integer ] ])
oN.Maximize("30*chairs + 45*tables")
oN.SubjectTo([ "2*chairs + 5*tables <= 250", "chairs <= 60", "tables <= 60" ])
oN.Solve()
? @@( oN.Solution() )
#--> [ [ "chairs", 60 ], [ "tables", 26 ] ]
? oN.Objective()
#--> 2970
? oN.Branched()
#--> 1
```

## 7. Abin da ba za a iya yi ba

Nemi x aƙalla ashirin yayin da x ba zai iya wuce goma ba, injin ya ce samfurin ba mai yiwuwa ba ne. Wannan
amsa ce, kuma ita ce ta gaskiya.

```ring
oF = new stzOptimModel()
oF.Vars([ :x = [ 0, 10 ] ])
oF.Maximize("x")
oF.SubjectTo([ "x >= 20" ])
oF.Solve()
? oF.StatusWord()
#--> infeasible
```

## 8. Ƙi biyu

Matakin inji da ba a gina ba ana ƙin sa da suna maimakon a maye gurbinsa a shiru, kuma jumlar da ɗakin karatu
ba zai iya karantawa ba tare da zato ba ana ƙin ta maimakon a zata.

```ring
try
	oM.SolveWith(:highs)
catch
	? "refused"
done
#--> refused
try
	StzOptimNaturally("maximize x where x is roughly 5")
catch
	? "refused"
done
#--> refused
```

## 9. A kan duniyarka

Ma'aikata biyu suna raba buƙatun wannan makon a makarantarka: kowanne zai iya ɗaukar a mafi yawa dukkan
makon, kuma ofishin yana son a kula da buƙatu mafi yawa. Abin da yake bugawa ya danganta da duniyar da wannan
darasin ke gudana a kanta, don haka shafin ba ya nuna sakamako: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
nR = len(aReq)
oW = new stzOptimModel()
oW.Vars([ :a = [ 0, :integer ], :b = [ 0, :integer ] ])
oW.Maximize("a + b")
oW.SubjectTo([ "a + b <= " + nR, "a <= " + nR, "b <= " + nR ])
oW.Solve()
? EduWorldName()
? oW.Objective()
```

{{exercise:math-12-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka rubuta shawara a matsayin samfuri, ka warware ta, ka karanta labarin injin kansa,
  ka duba mafi kyawun shiri da hannu, ka rubuta samfuri ɗaya a matsayin jumla ka ga biyun sun yarda a matsayin
  tsari na zahiri ɗaya, ka tsara samarwa, ka haɗu da samfuri mara yiwuwa da ƙi biyu.
- **Dalilin da ya sa yake da muhimmanci:** shawarar da aka rubuta a matsayin samfuri tana faɗin abin da take
  so da abin da dole ta riƙe, kuma babu kome game da yadda. Injin yana samun mafi kyawun shiri, ya ambaci
  kansa, kuma shirin magana ce da za ka iya duba.
- **Abin da ke zuwa:** kallon farko na Tukey ga bayanai, da zarar an gina matakin Tukey. Bayansa, ɗerivative da
  take duba dabara.
