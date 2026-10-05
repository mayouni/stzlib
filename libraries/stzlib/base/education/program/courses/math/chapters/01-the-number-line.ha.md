# Layin lambobi

*Lissafi · Babi na 1 · Ƙwarewa SE-01: "Shin hoto zai amsa da sauri fiye da lamba?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Lamba wuri ce. Uku, da debe biyu, da bakwai da rabi, wurare uku ne a kan layi ɗaya, kuma wannan layin shi ne
hoton farko na lissafi: duk abin da ke kansa yana da matsayi, da tsari, da nisa. Wannan babin yana bayyana
layin lambobi a hanyar Softanza. Kai ka faɗi abin da ke kansa; siffar ta lissafa inda kowane abu zai je, ta
zana shi, kuma ta yi wa hotonta hukunci kafin ka amince da shi.

## 1. Bayyana layin

Ana bayyana layin lambobi da maɓallai: tazarar da yake rufewa, da makin da ke kansa. Siffar tana amsawa da
jumla ɗaya game da abin da ta lissafa.

```ring
oL = StzMathFigureQ(:NumberLine, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5 ] ])
? oL.Why()
#--> a number line from -5 to 10: 16 ticks, 3 point(s), 0 jump(s)
```

## 2. Hoton yana yi wa kansa hukunci

Kowace siffa tana da dokoki. Layin lambobi dole ne ya kiyaye makinsa bisa tsarin lambobinsu, ya sauka da
tsalle inda tsallen ya faɗa, kuma ya bar kowane suna a karanta kusa da makinsa. Tambayi siffar ko hotonta ya
karya wata doka. Sifili ita ce amsar da kake so, kuma an lissafa ta, ba a yi alkawarinta ba.

```ring
? len( oL.Violations() )
#--> 0
```

## 3. Tsari tambaya ce da za ka iya yi

Wanne ya fi zuwa hagu, debe biyu ko uku? A kan layin, hagu yana nufin ƙarami. Softanza tana amsawa da lamba:
ɗaya na gaskiya, sifili na ƙarya.

```ring
? -2 < 3
#--> 1
? 7.5 < 3
#--> 0
```

## 4. Tsalle bambanci ne

Ana zana tsalle daga wuri zuwa wani a matsayin baka, kuma siffar tana tabbatar da cewa bakan ya sauka inda ya
faɗa. Tsalle yana da ƙarshe biyu, kuma siffar tana ƙidaya su a matsayin maki. Daga tara zuwa huɗu tsalle ne
na debe biyar: yana zuwa hagu.

```ring
oJ = StzMathFigureQ(:NumberLine, [ :on = [ 0, 12 ], :jumps = [ [ 9, 4 ] ], :step = 1 ])
? oJ.Why()
#--> a number line from 0 to 12: 13 ticks, 2 point(s), 1 jump(s)
? 4 - 9
#--> -5
```

## 5. Nisa tsakanin wurare biyu

Nisa bambanci ne da aka cire alamarsa. Tsakanin debe biyu da bakwai da rabi akwai raka'a tara da rabi, ko
daga wane ƙarshe ka fara.

```ring
? fabs( 7.5 - (-2) )
#--> 9.50
? fabs( -2 - 7.5 )
#--> 9.50
```

## 6. Ba wa wuri suna

Maki na iya ɗaukar suna, kuma siffar tana sanya sunan inda za a karanta shi ba tare da ya taɓa layin, ko
alamomin, ko wani suna ba. Rabi yana tsakiyar hanya tsakanin sifili da ɗaya.

```ring
oN = StzMathFigureQ(:NumberLine, [ :on = [ 0, 2 ], :step = 0.5,
                                   :points = [ [ 0.5, "half" ], [ 1.5, "one and a half" ] ] ])
? oN.Why()
#--> a number line from 0 to 2: 5 ticks, 2 point(s), 0 jump(s)
? len( oN.Violations() )
#--> 0
```

## 7. A kan duniyarka

Wannan tantanin yana ƙidaya buƙatun da makarantarka ta karɓa a wannan makon, ya sanya adadin a kan layi. Abin
da yake bugawa ya danganta da duniyar da wannan darasin ke gudana a kanta, saboda haka shafin ba ya nuna
sakamako: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
oW = StzMathFigureQ(:NumberLine, [ :on = [ 0, 10 ], :points = [ [ len(aReq), "requests" ] ] ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-01-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka bayyana layin lambobi da tazararsa da makinsa, ka karanta jumlar siffar game da
  abin da ta lissafa, ka nemi ta yi wa hotonta hukunci, ka kwatanta wurare biyu, ka yi tsalle tsakaninsu, kuma
  ka auna nisansu.
- **Dalilin da ya sa yake da muhimmanci:** ana bayyana hoto, a lissafa shi, sannan a duba shi. Ba a zana kome
  a kansa da hannu ba, don haka babu abin da zai yi kuskure a kansa a ɓoye: kowace magana a wannan babin layi
  ne da siffar ta buga.
- **Abin da ke zuwa:** kaso sashe ne na dunƙule, kuma babi na gaba yana yi masa inuwa, ya kwatanta biyu, ya
  karanta hukunci daga hoton.
