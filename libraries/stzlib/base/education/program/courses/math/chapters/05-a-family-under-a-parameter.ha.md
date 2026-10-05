# Iyali ƙarƙashin ma'auni

*Lissafi · Babi na 5 · Ƙwarewa FO-04: "Zan iya faɗin abin da nake so in bar injin ya yanke yadda?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Rubuta harafi inda lamba take, aiki ɗaya ya zama iyali: a sau sin na x layi ɗaya ne ga kowace ƙima ta a.
Ma'auni shi ne wannan harafin da tazara da ƙima, kuma motsi shi ne iyalin da aka motsa. Wannan babin yana
bayyana motsi, ya motsa ma'auninsa, kuma ya karanta abin da ke motsi tare da shi a gudu biyu: layin nan take,
alamomin lokacin da ma'aunin ya daidaita.

## 1. Bayyana iyalin

Bayyanar ta siffar aiki ce, da ma'aunin a rubuce cikin baka masu lanƙwasa. Sannan a ba ma'aunin tazararsa da
inda ya fara.

```ring
oM = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3 ])
oM.Param("a", 1, 3, 1)
? oM.Value("a")
#--> 1
```

## 2. Daidaita: siffar inda ma'aunin yake tsaye

Daidaitawa tana gina ta warware siffar ga ƙimar ma'aunin ta yanzu. Bayyanar da take amfani da ita ita ce
iyalin da aka maye gurbin harafin da lambar.

```ring
oM.Settle()
? @@( oM.Resolved() )
#--> [ "f", "(1) * sin(x)" ]
? oM.Figure().Why()
#--> a function figure: 400 samples in 1 piece(s), 4 mark(s)
```

## 3. Motsa ma'aunin: layin ya bi nan take

Saita a zuwa biyu. Motsin yanzu yana jira, wato alamominsa har yanzu suna cewa ɗaya yayin da layinsa ya riga
ya ce biyu. An ɗauki samfurin layin daga iyalin da aka tara sau ɗaya da a a matsayin mai canzawa: wurare ɗari
biyu da arba'in, kowanne an duba shi a nan da sin na Ring kanta.

```ring
oM.Set("a", 2)
? oM.IsDirty()
#--> 1
? oM.LiveSampleCount()
#--> 240
aS = oM.LiveSamples()
? fabs( aS[100][2] - 2 * sin( aS[100][1] ) ) < 0.000001
#--> 1
```

## 4. Daidaita kuma: alamomin sun cim ma

Ƙololuwar biyu sau sin suna a ƙari da debe biyu, inda ƙololuwar sin suke a ƙari da debe ɗaya. An sake samun
su, ba an girmama su ba.

```ring
oM.Settle()
? @@( oM.Figure().Extrema() )
#--> [ [ -1.57, -2 ], [ 1.57, 2 ], [ -4.71, 2 ], [ 4.71, -2 ] ]
? oM.IsDirty()
#--> 0
```

## 5. Yanayin da aka bayyana

Ana iya ba da labarin motsi a matsayin yanayi: kowanne taken da aikin da ya kai gare shi. Gaskiyar da aka ɗaure
da yanayi ana lissafa ta a kan hoton a wannan yanayin kuma a nuna ta a cikin taken inda ka rubuta sunanta cikin
baka masu lanƙwasa.

```ring
oM.State("With a at one, the mark nearest the origin sits at {top}.", [ [ :Set, "a", 1 ] ])
oM.StateFact("top", :datum, [ "m1", "y" ])
oM.State("With a at three it sits at {top}.", [ [ :Set, "a", 3 ] ])
oM.StateFact("top", :datum, [ "m1", "y" ])
? oM.NumberOfStates()
#--> 2
```

## 6. Aiwatar da yanayi, karanta gaskiyar

Aiwatar da yanayi na biyu yana saita a zuwa uku ya daidaita. Alamar da ta fi kusa da asali mafi ƙanƙanta ce,
kuma tsayinta debe uku ne: ma'aunin, an karanta shi daga hoton da aka warware.

```ring
oM.Apply(2)
? oM.Picture().Fact(:datum, [ "m1", "y" ])[:message]
#--> m1 carries y = -3
? oM.Applied()
#--> 2
```

## 7. Abin da motsin yake ƙi

Ma'aunin da bayyanar ba ta taɓa rubutawa ba ana ƙin sa da suna, haka kuma yanayin da aikinsa ba aiki ba ne.

```ring
try
	oM.Param("b", 0, 1, 0.5)
catch
	? "refused"
done
#--> refused
```

{{exercise:math-05-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka bayyana iyalin ayyuka ƙarƙashin ma'auni, ka daidaita shi, ka motsa ma'aunin ka ga
  layin ya bi nan take yayin da alamomin suka jira daidaitawa, ka duba samfurin rayayye da sin na Ring kanta,
  ka bayyana yanayi biyu da gaskiyar da aka ɗaure, kuma ka aiwatar da ɗaya.
- **Dalilin da ya sa yake da muhimmanci:** hoton da ke motsi ba fim ba ne. Ana sake lissafa layin kuma a sake
  samun alamomin, don haka abin da kake gani a kowace ƙima ta ma'aunin an duba shi kamar yadda aka duba hoton
  da ba ya motsi.
- **Abin da ke zuwa:** gini ma ana bayyana shi. Babi na gaba yana bayyana alwatika mai kusurwa dama da alwatika
  a cikin rabin da'ira, ya ja kusurwa, kuma ya karanta ka'ida daga haɗin gwiwar wurare.
