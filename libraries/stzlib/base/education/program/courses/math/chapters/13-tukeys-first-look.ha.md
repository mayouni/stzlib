# Kallon farko na Tukey

*Lissafi · Babi na 13 · Ƙwarewa SE-02: "Ina, kuma nawa?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Babi na 9 ya taƙaita ƙimomi takwas da ma'ana, matsakaici da kwata. John Tukey ya nemi kallon farko wanda
ƙima mai nisa ba za ta iya ja ba: tsakiyar tarin da aka jera, madogarai biyu a kwata na tafiya daga kowane
ƙarshe, da shinge wanda ƙima take tsaya ita kaɗai a bayansa. Wannan babin yana ɗaukar ƙimomi takwas ɗaya ta
cikin kalmominsa, sannan ya daidaita tebur gabaki ɗaya da matsakaitai, ya zana abin da bai dace ba, kuma ya
bar rahoto ya faɗi ko daidaitawar tana bayyana kowane gida.

## 1. Madogarai da faɗin kwata

Madogarai su ne ƙimomi biyu a kwata na tafiya daga kowane ƙarshe, a zurfin da Tukey ya lissafa daga adadi;
faɗin kwata shi ne nisan da ke tsakaninsu. A kan maki takwas matsakaici 6 ne, madogarai 4 da 10.5, kuma
jumlar taƙaitawar kanta tana faɗin wace ƙa'ida ta bi.

```ring
aV = [ 2, 4, 4, 5, 7, 9, 12, 25 ]
oS = StzTukeySummaryQ(aV)
? oS.Why()
#--> a Tukey summary of 8 value(s) under Tukey's fourths (hinges at depth (floor((n+1)/2)+1)/2): hinges 4 | 6 | 10.5, fourth-spread 6.5, 1 outside, 0 far out
? @@( oS.Fourths() )
#--> [ 4, 10.50 ]
? oS.FourthSpread()
#--> 6.50
```

## 2. Shinge, da abin da ke bayansa

Shinge yana tsaye a sau ɗaya da rabi na faɗin kwata bayan kowane madogara; ƙimar da ke bayansa "waje" ce.
Shinge na biyu, a sau uku, yana nuna "nesa sosai". Ashirin da biyar tana bayan shinge na farko kuma cikin na
biyu: waje, ba nesa sosai ba.

```ring
? @@( oS.OutsideFences() )
#--> [ -5.75, 20.25 ]
? @@( oS.Outside() )
#--> [ 25 ]
? @@( oS.FarOut() )
#--> [ ]
```

## 3. Ƙimomin haruffa

Shiga daga kowane ƙarshe rabi-rabi yana ba da ƙimomin haruffa: M ga matsakaici, F ga kwata, E ga takwas.
Kowane layi yana buga zurfinsa, ƙimomi biyun, tsakiyarsu da faɗinsu; tsakiya da take karkata daga matsakaici
yayin da haruffa suke fita ita ce yadda tari yake nuna ya karkata.

```ring
? oS.LetterValueTable(3)
#-->        F    2.5        4     7.25     10.5      6.5
#-->        E    1.5        3    10.75     18.5     15.5
```

## 4. Kowane lamba an riƙe

Zanen kara-da-ganye yana riƙe kowace ƙima a gani: goma-goma a matsayin kara, ɗaya-ɗaya a matsayin ganye da
aka jera, da bayani da yake faɗin abin da layi yake nufi.

```ring
oP = StzMathFigureQ(:StemPlot, [ :of = aV ])
? oP.Text()
#-->   0 | 2 4 4 5 7 9
#-->   leaf unit 1 -- 1 | 2 means 12
```

## 5. Tebur da aka daidaita da matsakaitai

Ana daidaita tebur mai hanya biyu a matsayin ƙima ɗaya ta gama-gari da tasirin layi da tasirin shafi, kowanne
an same shi da matsakaitai bi da bi, kuma abin da ya rage shi ne saura. Yarjejeniyar daidai ce: kowane gida
yana daidai da daidaitawarsa da saurarsa, kuma daidaitawar tana buga mafi girman gibi da ta samu, wanda shi
ne sifili.

```ring
aDeaths = [ [ 14, 15, 14 ], [ 7, 4, 7 ], [ 8, 2, 10 ], [ 15, 9, 10 ], [ 0, 2, 0 ] ]
oF = StzTukeyFitQ(aDeaths)
oF.Polish()
? oF.Common()
#--> 8
? @@( oF.Effects(:Row) )
#--> [ 6, -1, 0, 2, -8 ]
? oF.Residual(3, 2)
#--> -5
? oF.Check()
#--> 0
```

## 6. Abin da bai dace ba, a zane

Hoton saura-a-kan-daidaitawa yana sanya kowane gida a ƙimarsa da aka daidaita da saurarsa, da shingayen
saura a matsayin layuka. Jumlar hoton tana ƙidaya gidajen da ke bayan shingaye; dokokinsa suna sake lissafa
kowane ɗigo daga tebur kuma ba su bayar da rahoton wani karya ba.

```ring
aNames = [ [ "1-24", "25-74", "75-199", "200++", "NA" ], [ "1973", "1974", "1975" ] ]
oRes = StzMathFigureQ(:ResidualPlot, [ :of = aDeaths, :names = aNames ])
? oRes.Why()
#--> a residual-versus-fit of 5 x 3 cells: common 8, residual fourth-spread 1, 4 beyond the outside fences, 2 far out, 3 ringed on another cell's spot; nothing to lay out -- no rule minted an unknown
? len( oRes.Violations() )
#--> 0
```

## 7. Daidaitawa ɗaya, a lambobi

Teburin lambobi yana nuna kowace saura da alama ta rukuninta a kan ma'auni, kuma yana buga bayani tare da
ma'auni, in ba haka ba teburin ƙarya ne. Tauraron da ke layin 75-199 ƙarƙashin 1974 shi ne gidan da
daidaitawar ta fi rasa.

```ring
oC = StzMathFigureQ(:CodedTable, [ :of = aDeaths, :names = aNames ])
? oC.Text()
#-->   75-199     .    *    ^
#-->   scale 1 = the residuals' fourth-spread; common 8; hinges: Tukey's fourths
```

## 8. Rahoto yana faɗin ko daidaitawa ta tsaya

Kowane bincike sakamako ne a siffar gida, kuma rahoto ɗaya a kan daidaitawa yana amsa ko teburin lafiya
yake. Gidaje biyu suna bayan shingen "nesa sosai", don haka ba lafiya ba ne, kuma kuskuren farko yana faɗin
wane gida da nawa.

```ring
oRep = StzTukeyReportQ("deaths", [ oF ])
? oRep.IsSound()
#--> 0
aE = oRep.Errors()
? len( aE )
#--> 2
? aE[1][:message]
#--> residual -5 lies 5 fourth-spread(s) past the hinge, beyond the far-out fence at 3
```

## 9. Labari da ba ya lissafa kome

Labarin yana ba da daidaitawa da sakamakon a rubutu. Kowace lamba a cikinsa ana karanta ta daga daidaitawa ko
daga sakamako, ba a lissafa ta a cikin ba da labari ba, kuma labarin yana duba wannan da'awar a kan kansa.

```ring
oSt = StzTukeyStoryQ(oF, oRep)
acP = oSt.Paragraphs()
? acP[1]
#--> A table of 5 rows and 3 columns was fitted by median polish, which converged in 2 sweep(s). The common value is 8 and the residuals' fourth-spread, the scale every judgement below is in, is 1.
? oSt.IsHonest()
#--> 1
```

{{exercise:math-13-01}}

## Recap

- **An cimma:** ka taƙaita tari da madogarai, faɗin kwata da shingaye waɗanda ƙima mai nisa ba za ta iya ja
  ba, ka karanta ƙimomin haruffa da kara-da-ganye, ka daidaita tebur da matsakaitai ƙarƙashin yarjejeniya
  daidai, ka ga abin da bai dace ba a zane hanyoyi biyu, kuma ka bar rahoto da labari su faɗi abin da
  daidaitawa take bayyana da abin da ba ta bayyana ba.
- **Me ya sa yake da muhimmanci:** taƙaitawa da matsakaitai tana jurewa: ƙima mai nisa ɗaya tana motsa
  ma'ana da layin mafi ƙanƙantar murabba'ai, ta bar matsakaici da daidaitawa ta matsakaitai inda suke.
  Shingaye suna mai da "ya yi kama da baƙon abu" doka, kuma rahoto yana mai da dokar hukunci da shiri zai
  iya tsayawa a kai.
- **Mai zuwa:** derivative da yake duba dabara, a babi na gaba.
