# Kaso

*Lissafi · Babi na 2 · Ƙwarewa PA-02: "Mene ne siffar wannan jerin ko waɗannan lambobin?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Kaso sashe ne na dunƙule: uku daga cikin sassa huɗu daidai, an yi musu inuwa. Idan aka faɗe shi haka ya
riga ya zama hoto, kuma hoton yana amsa tambayoyin da mutane ke yi game da kasoshi da sauri fiye da lambobi.
Wanne daga cikin biyu ya fi girma? Waɗannan biyun adadi ɗaya ne? Wannan babin yana bayyana kasoshi a matsayin
siffofi, ya yi musu inuwa, ya kwatanta su gefe da gefe, kuma ya karanta kowane hukunci sau biyu: sau ɗaya daga
hoton, sau ɗaya ta hanyar lissafi.

## 1. Uku daga cikin huɗu

Ana bayyana siffar kaso da abin da take kaso na shi. Siffar tana gina dunƙule, ta yanka shi sassa daidai,
kuma ta yi wa darajar mai ƙidaya inuwa.

```ring
oF = StzMathFigureQ(:Fraction, [ :of = [ 3, 4 ], :label = "three of four" ])
? oF.Why()
#--> a fraction figure of 1 whole(s) as bars: 3 of 4 shaded
```

## 2. Hoton yana yi wa kansa hukunci

Siffar kaso tana da dokoki uku: sassan da aka yi wa inuwa su ne mai ƙidaya, sassan su ne mai raba, kuma sassan
suna cika dunƙulen ba tare da ragowa ba. Siffar tana ƙidaya su a kan hotonta.

```ring
? len( oF.Violations() )
#--> 0
```

## 3. Kasoshi biyu gefe da gefe

Idan aka bayyana su tare, kasoshi biyu suna raba faɗi ɗaya, don haka ido yana kwatanta su ba tare da awo ba.
Tsakanin kowane biyu siffar tana rubuta hukuncinta.

```ring
oC = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ] ] ])
? oC.Why()
#--> a fraction figure of 2 whole(s) as bars: 3 of 4 shaded, 2 of 3 shaded
```

## 4. Hukuncin, an duba shi da lissafi

Hoton ya ce kwata uku ya fi sulusi biyu girma. Lissafi ya faɗi haka ma, ta hanyar ninkawa a giciye: kwatanta
uku sau uku da biyu sau huɗu. Bangarorin biyu suna amsawa da ɗaya, wanda shi ne kalmar Softanza ta gaskiya.

```ring
? 3 * 3 > 2 * 4
#--> 1
? 3/4 > 2/3
#--> 1
```

## 5. Sunaye biyu na adadi ɗaya

Biyu daga cikin huɗu da ɗaya daga cikin biyu suna yin inuwa ga faɗi ɗaya. Siffar tana rubuta alamar daidai
tsakaninsu, kuma sakamakon ninkawa a giciye sun yarda.

```ring
oE = StzMathFigureQ(:Fraction, [ :compare = [ [ 2, 4 ], [ 1, 2 ] ] ])
? oE.Why()
#--> a fraction figure of 2 whole(s) as bars: 2 of 4 shaded, 1 of 2 shaded
? 2 * 2 = 1 * 4
#--> 1
```

## 6. A matsayin faifai

Ana iya yi wa kasoshin nan inuwa a matsayin yankunan faifai. Hukuncin hoto ɗaya ne da aka tambaya ta wata
hanya.

```ring
oD = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 8 ], [ 1, 4 ] ], :as = :disc ])
? oD.Why()
#--> a fraction figure of 2 whole(s) as discs: 3 of 8 shaded, 1 of 4 shaded
? 3 * 4 > 1 * 8
#--> 1
```

## 7. Abin da siffar take ƙi

Siffar kaso tana nuna sashe na dunƙule ƊAYA, don haka ana ƙin mai ƙidaya da ya fi mai rabansa girma da suna,
haka kuma mai raba da ya yi laushi da ba za a iya zana shi ba.

```ring
try
	StzMathFigureQ(:Fraction, [ :of = [ 5, 4 ] ])
catch
	? "refused"
done
#--> refused
```

## 8. A kan duniyarka

Daga cikin dukkan buƙatun da makarantarka ta karɓa a wannan makon, wane kaso ne ya nemi takardar sakamako?
Adadin ya danganta da duniyar da wannan darasin ke gudana a kanta, don haka shafin ba ya nuna sakamako:
gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
oW = StzMathFigureQ(:Fraction, [ :of = [ nT, len(aReq) ], :label = "transcripts among the requests" ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-02-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka bayyana kaso a matsayin siffa mai inuwa, ka kwatanta kasoshi biyu gefe da gefe,
  ka karanta hukuncin siffar, kuma ka duba shi ta hanyar ninkawa a giciye; ka ga sunaye biyu na adadi ɗaya, da
  abin da siffar take ƙi.
- **Dalilin da ya sa yake da muhimmanci:** hukuncin da aka karanta daga hoto da hukuncin da aka lissafa amsoshi
  biyu ne masu zaman kansu ga tambaya ɗaya. Idan sun yarda za ka iya amincewa da su duka; idan sun saɓa, wani
  abu ya yi kuskure kuma ka san haka kafin kowa.
- **Abin da ke zuwa:** wasan dama mai kusurwoyi uku da doka ɗaya yana zana siffa da babu wanda ya zana. Babi
  na gaba yana buga shi kuma ya ƙidaya abin da ya bayyana.
