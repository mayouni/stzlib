# Daidaito ba dubawa ta kai ba ce

*Lissafi · Babi na 15 · Ƙwarewa CR-02: "Me zai karye idan na yi kuskure?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Dubawa tana da daraja daidai da damar kasawarta. Lissafa lamba daga dabara, sannan ka duba dabarar a kan
lambar da ka lissafa yanzu, dubawar za ta wuce ko me dabarar ta faɗa: daidaito ne, kuma daidaito ba ya
tabbatar da kome. Dubawa ta gaske tana kwatanta hanyoyi biyu masu zaman kansu zuwa gaskiya ɗaya, kuma dole
ta iya kasawa. Wannan babin yana gina dubawa da ba za ta iya kasawa ba, sannan magana ɗaya da aka duba da
hoto da bai taɓa jin dabarar ba, da algorithm na biyu, da tef, kuma ya nuna mara tabbaci da kowane tabbatacce
ke buƙata.

## 1. Dubawa da ba za ta iya kasawa ba

Lissafa hypotenuse daga gefuna biyu da dabarar, sannan ka "duba" dabarar a kanta. Sifili, koyaushe.

```ring
a = 3
b = 4
c = sqrt( a*a + b*b )
? a*a + b*b - c*c
#--> 0
```

## 2. Dabara mara kyau tana duba kanta daidai haka

Ƙara ɗaya a cikin tushen, abin da babu alwatika mai kusurwa dama da ta ba da izini, ka duba dabarar mara kyau
a kan lambarta. Sifili kuma. Dubawar ba ta lura ba, saboda ba za ta iya ba.

```ring
c2 = sqrt( a*a + b*b + 1 )
? a*a + b*b + 1 - c2*c2
#--> 0.00
```

## 3. Hoton da bai taɓa jin dabarar ba

Hoton Byrne na babi na 6 an warware shi daga maki uku da kusurwa dama; daidaiton murabba'an bai taɓa zama
doka ba. Auna gefunansa uku ka duba dabarar a kan awo da ba su fito daga gare ta ba. Yanzu dubawar ta iya
kasawa, kuma ba ta kasa ba.

```ring
oP = StzPythagorasPictureQ( StzMathFigureFont() )
nAB = oP.Fact(:distance, [ "A.icon", "B.icon" ])[:value]
nAC = oP.Fact(:distance, [ "A.icon", "C.icon" ])[:value]
nBC = oP.Fact(:distance, [ "B.icon", "C.icon" ])[:value]
? fabs( nBC*nBC - nAB*nAB - nAC*nAC ) < 0.01
#--> 1
```

## 4. Algorithm biyu ga lamba ɗaya

Siffar aiki tana samun sifili na x murabba'i debe uku ta hanyar kewaye sauyin alama. Tushen murabba'i na Ring
yana samun lamba ɗaya ta wani algorithm. Hanyoyi biyu, gaskiya ɗaya, zuwa ɗaya cikin miliyan.

```ring
oFig = StzMathFigureQ(:Function, [ :f = "x^2 - 3", :on = [ -3, 3 ], :mark = [ :zeros ] ])
aZ = oFig.Zeros()
z = aZ[1][1]
? z
#--> 1.73
? fabs( z - sqrt(3) ) < 0.000001
#--> 1
```

## 5. Mara tabbaci da kowane tabbatacce ke buƙata

Dubawa da ta ce e shaida ce kawai idan da za ta ce a'a ga amsa mara kyau. Ba ta ɗaya: ɗaya da rabi ba tushen
uku ba ne, kuma dubawa ɗaya ta ƙi shi.

```ring
? fabs( 1.5 * 1.5 - 3 ) < 0.000001
#--> 0
```

## 6. Tef a matsayin hanya ta uku

Babi na 4 ya samu ƙololuwar x murabba'i debe biyu ta hanyar kallon layin yana juyawa; babi na 14 ya karanta
gangaren daga tef. Ƙololuwa inda gangaren sifili ne, kuma tef ya yarda ba tare da ya kalli layin ba.

```ring
oQ = new stzMathFunction("x^2 - 2", [ "x" ])
? oQ.DerivativeAt("x", [ 0 ])
#--> 0
? oQ.DerivativeAt("x", [ 1 ])
#--> 2
```

## 7. A kan duniyarka

Ƙidaya buƙatun wannan makon a makarantarka hanyoyi biyu: tsawon jerin, da jimlar ƙidaya bisa iri. Hanyoyi
biyu zuwa lamba ɗaya; shafin ba ya nuna sakamako, saboda ya danganta da duniyar: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
nSum = 0
for i = 1 to len(aKinds)
	nSum += StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
? EduWorldName()
? len(aReq)
? nSum
```

{{exercise:math-15-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka gina dubawa da ba za ta iya kasawa ba ka ga ta karɓi dabara mara kyau, sannan ka
  duba magana ɗaya a kan hoton da bai taɓa jin ta ba, a kan algorithm na biyu, da a kan tef, kuma ka ba
  dubawar amsa mara kyau ta ƙi.
- **Dalilin da ya sa yake da muhimmanci:** kowace magana a wannan darasin ta ɗauki dubawarta, kuma wannan
  babin yana faɗin abin da ya sa waɗannan dubawar suka yi daraja: sun kwatanta hanyoyi masu zaman kansu, kuma
  kowace ta iya kasawa.
- **Abin da ke zuwa:** wannan shi ne babi na ƙarshe da aka rubuta. Kallon farko na Tukey ga bayanai yana
  ɗaukar babi na 13 lokacin da aka gina matakin Tukey, kuma darasin yana buga shi a matsayin an tsara ba a
  rubuta ba har zuwa lokacin.
