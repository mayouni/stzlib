# Ƙididdiga a matsayin harshen tunani

*Lissafi · Babi na 9 · Ƙwarewa FO-01: "Me nake tambaya da gaske, cikin ƙananan kalmomi?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Lambobi takwas gaskiya takwas ne. Ƙididdiga harshe ne da yake faɗin abin da suka yi tarayya a kalmomi kaɗan,
kuma akwati shi ne wannan harshen a zane: inda tsakiya take, faɗin rabin tsakiya, da wace ƙima ce ta tsaya
ita kaɗai. Wannan babin yana ɗaukar ƙimomi takwas ta cikin kalmomi, sannan ta cikin hoto, kuma ya duba cewa
biyun suna faɗin abu ɗaya.

## 1. Ƙimomi takwas, tsakiya biyu

Ma'ana tana ƙara kome ta raba. Matsakaici ita ce ƙima a tsakiya bayan an jera ƙimomin. Babbar ƙima ɗaya tana
ja ma'ana sama ta bar matsakaici inda take.

```ring
aV = [ 2, 4, 4, 5, 7, 9, 12, 25 ]
oD = new stzDataSet(aV)
? oD.Mean()
#--> 8.50
? oD.Median()
#--> 6
```

## 2. Kwata da wadda ta tsaya ita kaɗai

Kwata suna yanka ƙimomin da aka jera zuwa sassa huɗu. Ƙima da ta yi nisa bayan rabin tsakiya ƙima ce da ta
fita, kuma tarin bayanan yana ambatarta.

```ring
? @@( oD.Quartiles() )
#--> [ 4, 6, 9.75 ]
? @@( oD.Outliers() )
#--> [ 25 ]
```

## 3. Kalmomi ɗaya, a zane

Ana bayyana siffar akwati da ƙimominta. Jumlarta tana faɗin lambobi ɗaya da tarin bayanan ya faɗa: akwatin
daga kwata ta farko zuwa ta uku, matsakaici a ciki, da ƙimar da ta fita an ƙidaya.

```ring
oB = StzMathFigureQ(:BoxPlot, [ :of = aV, :label = "eight values" ])
? oB.Why()
#--> a box plot of 1 group(s): n = 8, box 4 | 6 | 9.75, 1 outlier(s)
? len( oB.Violations() )
#--> 0
```

## 4. Hoton a rubutu

Siffar za ta iya faɗin kanta a rubutu, don tasha, saƙo ko shafi ba tare da hoto ba: lambobin, sannan
akwatin, gashin baki da ƙimar da ta tsaya ita kaɗai.

```ring
? oB.Text()
#--> group 1  n=8  min 2  Q1 4  med 6  Q3 9.75  max 25  outliers 1
```

## 5. Ta fita bisa doka, ba bisa ra'ayi ba

Dokar shinge ce: sau ɗaya da rabi na faɗin akwatin, bayan kwata ta uku. Ashirin da biyar tana bayan shingen,
don haka gashin baki ya tsaya a goma sha biyu, ƙima ta ƙarshe a ciki.

```ring
aS = oD.BoxPlotStats()
? aS[:iqr]
#--> 5.75
? 9.75 + 1.5 * 5.75
#--> 18.38
? 25 > 18.375
#--> 1
? aS[:whisker_high]
#--> 12
```

## 6. Ƙungiyoyi biyu gefe da gefe

Ƙungiyoyi biyu suna raba layi ɗaya, don haka ido yana kwatanta tsakiyarsu ba tare da lamba ba. Safiya tana
da ƙima da ta fita; maraice ba ta da ita.

```ring
oG = StzMathFigureQ(:BoxPlot, [ :groups = [ [ "morning", [ 12, 15, 14, 18, 16, 15, 13, 40 ] ],
                                            [ "evening", [ 20, 22, 19, 25, 24, 21, 23, 22 ] ] ] ])
? oG.Why()
#--> a box plot of 2 group(s): morning n = 8, box 13.75 | 15 | 16.5, 1 outlier(s); evening n = 8, box 20.75 | 22 | 23.25, 0 outlier(s)
```

## 7. Yaɗuwa a matsayin lamba ɗaya

Karkata daidaitacciya tana faɗin nisan da ƙimomin suke daga ma'ana, a matsakaici. Lamba ɗaya ce ga dukkan
yaɗuwar, kuma ita ma ƙimar da ta tsaya ita kaɗai tana jan ta.

```ring
? oD.StandardDeviation()
#--> 7.39
```

## 8. A kan duniyarka

Buƙatu nawa na kowane iri makarantarka ta karɓa, a matsayin tarin bayanai: matsakaicin adadi ga kowane iri da
matsakaici. Abin da yake bugawa ya danganta da duniyar da wannan darasin ke gudana a kanta, don haka shafin
ba ya nuna sakamako: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
aCounts = []
for i = 1 to len(aKinds)
	aCounts + StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
oK = new stzDataSet(aCounts)
? EduWorldName()
? oK.Mean()
? oK.Median()
```

{{exercise:math-09-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka taƙaita ƙimomi takwas a kalmomi, ma'ana da matsakaici da kwata da ƙimar da ta
  fita, sannan ka zana su a matsayin akwati wanda jumlarsa da rubutunsa suke faɗin lambobi ɗaya, ka yi amfani
  da dokar shinge da hannu, ka kwatanta ƙungiyoyi biyu, kuma ka karanta yaɗuwa a matsayin lamba ɗaya.
- **Dalilin da ya sa yake da muhimmanci:** taƙaitawa magana ce game da lambobi masu yawa. Idan kalmomi, hoto
  da doka sun yarda, an duba maganar ta hanyoyi uku; idan ɗaya ya saɓa, ka san wanne.
- **Abin da ke zuwa:** dama. Babi na gaba yana jefa tsabar kuɗi sau dubu ya karanta rabon a kan ci gaba daga
  kaɗan zuwa mafi yawa.
