# Ilimin siffofi an bayyana kuma an warware

*Lissafi · Babi na 6 · Ƙwarewa CR-02: "Me zai karye idan na yi kuskure?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Ba a zana hoton ilimin siffofi: ana bayyana shi a warware shi. Ka faɗi abin da ke akwai, maki uku da alwatika,
da'ira da abin da ke kanta, kuma mai warwarewa ya samu haɗin gwiwar wurare da suke kiyaye kowace doka. Ka'ida
kuwa abu ne da kake karantawa daga haɗin gwiwar wuraren da aka warware, ba abin da ka gaya wa hoton ya sa ya
zama gaskiya ba. Wannan babin yana gina hotuna biyu da ɗakin karatu ke ajiyewa a matsayin labarai, I.47 na
Euclid a launukan Byrne da ka'idar Thales, ya ja kusurwa a kowanne, kuma ya sake karanta ka'idar a kowane
matsayi.

## 1. Alwatikar Byrne mai kusurwa dama

Maki uku, alwatika, kusurwa dama a A: abin ya faɗi haka kawai, kuma salon ya samo kowane murabba'i daga makin
uku. Tambayi hoton da aka warware mene ne kusurwa a A.

```ring
oP = StzPythagorasPictureQ( StzMathFigureFont() )
? oP.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
```

## 2. Ka'idar da aka karanta daga haɗin gwiwar wurare

Babu abin da ke cikin hoton da yake tabbatar da cewa ƙananan murabba'ai biyu suna yin babban. Bayanin da ke
ƙasa shi ne bambancin da ke tsakaninsu, an lissafa shi daga makin da aka warware, kuma ya fi ɗari ɗaya na
murabba'in pixel ƙanƙanta.

```ring
aGap = oP.Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])
? fabs( aGap[:value] ) < 0.01
#--> 1
```

## 3. Ja kusurwa: ka'idar ta tsaya

Motsi a kan hoton yana jan A. Murabba'an an samo su daga makin, don haka suna bi; kusurwa dama doka ce, don
haka mai warwarewa ya kiyaye ta; daidaiton bai taɓa zama doka ba, kuma ya tsaya duk da haka.

```ring
oM = StzMathMotionOverQ(oP)
oM.State("A moved: a^2 + b^2 - c^2 = {gap} px^2", [ [ :DragBy, "A.icon", 60, -30 ] ])
oM.StateFact("gap", :expr, [ StzPythagorasGapExpr(), "px^2" ])
oM.Apply(1)
? oM.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? fabs( oM.Picture().Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])[:value] ) < 0.01
#--> 1
```

## 4. Thales: maki uku a kan da'ira

Labari na biyu ya faɗi abubuwa uku: B da C suna kan da'irar, BC ta ratsa tsakiyarta, A yana kan da'irar. Bai
taɓa cewa kusurwa a A dama ce ba. Karanta shi.

```ring
oT = StzThalesPictureQ( StzMathFigureFont() )
? oT.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? oT.Substance().Holds("Right", [ "BAC" ])
#--> 0
```

## 5. Motsa A tare da da'irar

Ja A ko'ina. Mai warwarewa yana kiyaye A a kan da'irar da diamita ta cikin tsakiya, kuma kusurwa a A ta sake
karanta casa'in. Wannan ita ce ka'idar Thales: sakamakon ginin, a kowane matsayi.

```ring
oN = StzMathMotionOverQ(oT)
oN.State("A moved: the angle at A is {angle} degrees", [ [ :DragBy, "A.icon", 90, 40 ] ])
oN.StateFact("angle", :angle, [ "B.icon", "A.icon", "C.icon" ])
oN.Apply(1)
? oN.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? fabs( oN.Picture().Fact(:expr, [ "dist(A.icon, K.icon) - K.icon.r", "px" ])[:value] ) < 0.01
#--> 1
```

## 6. Abin da ja yake ƙi

Siffa ce kawai wadda mai warwarewa ya mallaki matsayinta za a iya ja. Murabba'in siffar Byrne an samo shi daga
makin, don haka yanayin da yake jan sa ana ƙin sa da suna.

```ring
try
	oM.State("x", [ [ :DragBy, "ABC.sqbc", 10, 10 ] ])
catch
	? "refused"
done
#--> refused
```

{{exercise:math-06-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka gina I.47 na Euclid da hoton Thales daga bayyanarsu, ka karanta kusurwa dama da
  daidaito daga haɗin gwiwar wuraren da aka warware, ka ja kusurwa a kowanne ta hanyar yanayin da aka bayyana,
  kuma ka sake karanta ka'idar inda kusurwar ta sauka.
- **Dalilin da ya sa yake da muhimmanci:** ka'idar da ba a taɓa neman hoton ya cika ba, kuma ya cika ta a
  kowane matsayi, shaida ce ta wani irin daban da zanen da aka yi don ya yi kama da daidai. Abin da zai karye
  idan ka'idar ba daidai ba ce shi ne ainihin abin da wannan babin ke karantawa.
- **Abin da ke zuwa:** lamba da take faɗin dalilin da ya sa ba ta zama daidai ba. Babi na gaba yana haɗuwa da
  lambobin ɗakin karatu daidai da lokacin da lissafi ya bar su.
