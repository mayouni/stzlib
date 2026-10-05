# Wasan hargitsi

*Lissafi · Babi na 3 · Ƙwarewa PA-02: "Mene ne siffar wannan jerin ko waɗannan lambobin?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Ɗauki kusurwoyi uku na alwatika da fensir a ko'ina a ciki. Jefa dara: ɗaya ko biyu yana nufin kusurwa ta
farko, uku ko huɗu ta biyu, biyar ko shida ta uku. Matsa rabin hanya daga inda kake zuwa wannan kusurwar, ka
sa ɗigo. Jefa kuma. Bayan jifa dubu biyu ɗigon ba tabo ba ne: alwatika ne cike da ramuka, siffa ɗaya a kowane
girma, da babu wanda ya zana. Wannan babin yana buga wasan da lambobin bazuwar ɗakin karatu, kuma ya ƙidaya
abin da ya bayyana maimakon sha'awarsa.

## 1. Kusurwoyi uku

Kusurwoyin wurare uku ne a kan shafi. Ba sa motsi; fensir kaɗai ke motsi.

```ring
? @@( StzChaosGameCorners() )
#--> [ [ 320, 40 ], [ 40, 560 ], [ 600, 560 ] ]
```

## 2. Jifa shida na farko

Kowane ɗigo bayanai ne: wuri da dokar ta samar. Iri yana sa jifan su zama iri ɗaya duk lokacin da wannan
tantanin ya gudana, don haka za a iya yin alkawari game da dama.

```ring
oS = StzChaosGameSubstance(6, 7)
for i = 1 to 6
	? "" + oS.DataOf("d" + i, "x") + ", " + oS.DataOf("d" + i, "y")
next
#--> 320, 170
```

## 3. Jifa dubu biyu

Hoton zane ne da babu abin da za a warware: ɗigo dubu biyu, kowanne an zana shi inda bayanansa suka faɗa.

```ring
oG = StzChaosGamePictureQ(StzMathFigureFont(), 2000, 7)
? oG.NumberOfShapes()
#--> 2000
? oG.NumberOfUnknowns()
#--> 0
```

## 4. Abin da ya bayyana, an ƙidaya

Alwatikar Sierpinski tana da alamu biyu. Kowane ɗigo yana cikin babbar alwatika, kuma babu ko ɗaya a cikin
ramin tsakiya, alwatikar da kusurwoyinta su ne tsakiyar gefuna. Ɗakin karatu yana ƙidaya duka biyun ta hanyar
gwaji mai zaman kansa a kan matsayin kowane ɗigo: ba a taɓa gaya wa dokar game da ramin ba.

```ring
aC = StzChaosGameCounts(oG, 2000)
? aC[1]
#--> 2000
? aC[2]
#--> 0
```

## 5. Dama, amma duk da haka siffa ɗaya

Wani iri yana ba da wasu jifa da wasu ɗigo, kuma ƙidaya biyun sun fito iri ɗaya. Siffar ta dokar ce, ba ta
jifan ba.

```ring
oH = StzChaosGamePictureQ(StzMathFigureFont(), 500, 11)
? @@( StzChaosGameCounts(oH, 500) )
#--> [ 500, 0 ]
```

## 6. Wurin ɗigo shi ne bayanansa

Hoton ba ya ɓoye kome: ana zana ɗigo daidai inda bayanansa suka sa shi, kuma za ka iya karanta duka biyun.

```ring
? oG.ValueOf("d7.icon.cx") = oG.Substance().DataOf("d7", "x")
#--> 1
```

{{exercise:math-03-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka buga wasan hargitsi da lambobin bazuwa masu iri, ka zana ɗigo dubu biyu ba tare da
  abin da za a warware ba, kuma ka ƙidaya alamu biyu na alwatikar Sierpinski ta hanyar gwaji mai zaman kansa
  maimakon amincewa da idanunka.
- **Dalilin da ya sa yake da muhimmanci:** tsarin da ya bayyana daga dama magana ce kamar kowace. Ƙidaya abin
  da dokar ta samar shi ne yadda hoto yake zama shaida.
- **Abin da ke zuwa:** aiki ma hoto ne. Babi na gaba yana zana ɗaya, ya yi alama inda ya ratsa sifili da inda
  ya juya, kuma ya duba kowace alama.
