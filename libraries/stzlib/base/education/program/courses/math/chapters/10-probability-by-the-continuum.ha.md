# Yiwuwa ta hanyar ci gaban masu ƙidaya

*Lissafi · Babi na 10 · Ƙwarewa KN-02: "Me ke biyo bayan abin da na rubuta?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Kafin yiwuwa ta samu lambobi tana da kalmomi: babu, kaɗan, wasu, rabi, da yawa, mafi yawa, duka. Softanza
tana riƙe waɗannan kalmomin a matsayin masu ƙidaya a kan jeri, kuma suna yin ci gaba wanda ɗakin karatu ke
riƙe tsarinsa. Yiwuwa kuwa rabo ne da za ka iya karantawa a kan wannan ci gaban, kuma jifa dubu na tsabar
kuɗi da aka shuka rabo ne da za ka iya ƙidaya. Wannan babin yana tafiya a kan ci gaban, ya jefa tsabar kuɗi,
ya jefa dara, kuma ya sanya abin da ya gani a kan layin lambobi.

## 1. Ci gaban, cikin tsari

Kowane mai ƙidaya yana ɗaukar rabo na jeri: kaɗan ƙaramin rabo, wasu babba, mafi yawa kusan duka. Ko wane
rabo, tsarin yana tsaye, kuma ɗakin karatu yana duba shi a kan lambobi goma.

```ring
aTen = 1:10
? len( Few(aTen) ) < len( Some(aTen) )
#--> 1
? len( Some(aTen) ) < len( Most(aTen) )
#--> 1
? len( All(aTen) )
#--> 10
? len( No(aTen) )
#--> 0
```

## 2. Rabi, daidai

Rabin goma biyar ne. Ƙidayar mai ƙidaya lamba ce da ɗakin karatu ke lissafawa, ba zato ba.

```ring
? len( Half(aTen) )
#--> 5
```

## 3. Jifa dubu na tsabar kuɗi mai adalci

Iri yana sa jifan su zama iri ɗaya kowane lokaci, don haka za a iya yin alkawari game da dama. Yiwuwar kai na
tsabar kuɗi mai adalci rabi ne; jifa dubu da iri uku suna ba da kawuna ɗari biyar da huɗu, cikin biyar cikin
ɗari na rabi.

```ring
SeedRandom(3)
nHeads = 0
for i = 1 to 1000
	if StzRandom01() < 0.5  nHeads++  ok
next
? nHeads
#--> 504
? fabs( nHeads / 1000 - 0.5 ) < 0.05
#--> 1
```

## 4. Jifa sittin na dara

Kowace fuska tana da yiwuwa ɗaya cikin shida, kuma jifa sittin ya kamata su nuna kowace fuska kusan sau goma.
Teburin mita yana ƙidaya abin da jifan da aka shuka suka bayar da gaske: kowace fuska ta bayyana, kuma babu
wadda ta bayyana sau da yawa kamar yadda dama za ta bar ta.

```ring
SeedRandom(3)
aRolls = []
for i = 1 to 60
	aRolls + ( floor( StzRandom01() * 6 ) + 1 )
next
oD = new stzDataSet(aRolls)
? len( oD.FrequencyTable() )
#--> 6
? @@( oD.FrequencyTable() )
#--> [ "1", 16 ]
```

## 5. Abin da aka gani, a kan layi

Rabon kawuna wuri ne tsakanin sifili da ɗaya. Zana shi a kan layin lambobi kusa da rabin tsabar kuɗi mai
adalci, biyun suna kusa amma ba wuri ɗaya ba: dama ita ce abin da ke tsakaninsu.

```ring
oL = StzMathFigureQ(:NumberLine, [ :on = [ 0, 1 ], :step = 0.1,
                                   :points = [ [ 0.5, "fair" ], [ nHeads / 1000, "seen" ] ] ])
? oL.Why()
#--> a number line from 0 to 1: 11 ticks, 2 point(s), 0 jump(s)
```

## 6. Jifa goma, a matsayin kaso

Daga jifa goma da aka shuka, shida nawa? Ƙidayar kaso ne na goma, an yi masa inuwa.

```ring
SeedRandom(5)
nSixes = 0
for i = 1 to 10
	if floor( StzRandom01() * 6 ) + 1 = 6  nSixes++  ok
next
? nSixes
#--> 1
oF = StzMathFigureQ(:Fraction, [ :of = [ nSixes, 10 ], :label = "sixes in ten rolls" ])
? oF.Why()
#--> a fraction figure of 1 whole(s) as bars: 1 of 10 shaded
```

## 7. A kan duniyarka

Daga cikin buƙatun da makarantarka ta karɓa a wannan makon, wane rabo ne ya nemi takardar sakamako, kuma
kaɗan ne, wasu ko mafi yawa? Abin da yake bugawa ya danganta da duniyar da wannan darasin ke gudana a kanta,
don haka shafin ba ya nuna sakamako: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
? EduWorldName()
? nT / len(aReq)
```

{{exercise:math-10-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka yi tafiya a kan ci gaban masu ƙidaya daga babu zuwa duka ka ga tsarinsa ya tsaya,
  ka jefa tsabar kuɗi da aka shuka sau dubu ka karanta rabon da rabi, ka jefa dara sau sittin ka ƙidaya kowace
  fuska, ka sanya rabon a kan layin lambobi kuma ka yi wa jifa goma inuwa a matsayin kaso.
- **Dalilin da ya sa yake da muhimmanci:** dama ba rashin magana ba ce. Da iri, jifa gaskiya ce da za ka iya
  yin alkawarinta; da ƙidaya, yiwuwa rabo ne da za ka iya duba.
- **Abin da ke zuwa:** kuɗi ba dole ba ne su rasa ko kwabo ɗaya. Babi na gaba yana ƙara ya raba kuɗi da lambobi
  daidai da suke faɗin dalilin da ya sa ba su zama daidai ba idan ba haka ba.
