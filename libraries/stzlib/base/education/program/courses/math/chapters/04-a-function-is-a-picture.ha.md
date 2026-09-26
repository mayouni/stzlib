# Aiki hoto ne

*Lissafi · Babi na 4 · Ƙwarewa SE-02: "Ina, kuma nawa?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Aiki doka ce da take mayar da lamba ɗaya zuwa wata, kuma hotonsa shi ne tarin dukkan wuraren da dokar ta kai.
Hoton yana amsa abin da dabarar ta ɓoye: inda dokar take ba da sifili, inda ta daina hawa ta fara sauka, inda
ta karye. Wannan babin yana bayyana aiki a matsayin siffa. Injin ne ya lissafa layin; alamomin da ke kansa
ana samun su, a sanya su, sannan a duba su ɗaya bayan ɗaya ta hanyar lissafi.

## 1. Bayyana aikin

Ana bayyana siffar aiki da dabararsa, tazarar da za a zana shi a kanta, da alamomin da kake son a samu.

```ring
oF = StzMathFigureQ(:Function, [ :f = "x^2 - 2", :on = [ -3, 3 ], :mark = [ :zeros, :extrema ] ])
? oF.Why()
#--> a function figure: 400 samples in 1 piece(s), 3 mark(s)
```

## 2. Inda ya zama sifili, da inda ya juya

Siffar ta samu sifili biyu da ƙololuwa ɗaya. Kowace alama wuri ne: x da y.

```ring
? @@( oF.Zeros() )
#--> [ [ 1.41, -0.00 ], [ -1.41, -0.00 ] ]
? @@( oF.Extrema() )
#--> [ [ 0, -2 ] ]
```

## 3. Alama magana ce, kuma ana duba maganar

Siffar ta ce layin ya zama sifili a 1.41. Lissafi ya duba: ninka wannan lambar da kanta ka cire biyu, abin da
ya rage ya fi ɗaya cikin miliyan ƙanƙanta. Siffar ta samu tushen murabba'i na biyu ba tare da an gaya mata
ba.

```ring
aZ = oF.Zeros()
z = aZ[1][1]
? z
#--> 1.41
? fabs( z * z - 2 ) < 0.000001
#--> 1
```

## 4. Hoton yana yi wa kansa hukunci

Siffar aiki tana da dokoki: alamar sifili tana kewaye sauyin alama, alamar ƙololuwa tana kewaye juyi, kuma
kowace bayani ana karanta shi kusa da alamarsa. Sifili keta an lissafa shi, ba a yi alkawarinsa ba.

```ring
? len( oF.Violations() )
#--> 0
```

## 5. An zaɓi taga daga layin

Siffar tana duba ƙimomin da ta lissafa ta bar iska sama da ƙasa da su, don haka alamomin ba sa taɓa firam.
Taga lambobi huɗu ne: daga da zuwa a kan x, sannan a kan y.

```ring
? @@( oF.Window() )
#--> [ -3, 3, -3.33, 8.33 ]
```

## 6. Wasu hanyoyin faɗar layi

Layi ba dole ne ya zama y na x ba. Da'ira x da y ne na lamba ta uku t, kuma fure nisa r ne na kusurwa t. Babu
alama a kan waɗannan layukan, don haka babu abin da za a warware: siffar ta faɗi haka.

```ring
oCircle = StzMathFigureQ(:Function, [ :x = "cos(t)", :y = "sin(t)", :t = [ 0, 6.2832 ], :label = "a circle" ])
? oCircle.Why()
#--> a function figure: 400 samples in 1 piece(s), 0 mark(s); nothing to lay out
oRose = StzMathFigureQ(:Function, [ :r = "cos(3*t)", :t = [ 0, 3.1416 ], :label = "a rose" ])
? oRose.Why()
#--> a function figure: 400 samples in 1 piece(s), 0 mark(s); nothing to lay out
```

## 7. Tangent a wurin da ka ambata

Nemi tangent a x daidai da ɗaya, siffar za ta ƙara alama da aka bayar a can, da tsayin layin a wannan wurin:
sin na ɗaya shi ne 0.84.

```ring
oT = StzMathFigureQ(:Function, [ :f = "sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :tangent = 1, :maxmarks = 4 ])
? @@( oT.Marks() )
#--> [ "given", 1, 0.84 ]
```

## 8. Inda dokar ta karye

Ɗaya a kan x debe ɗaya ba shi da ƙima a x daidai da ɗaya. Siffar ba ta zana ta cikin karyewar: tana zana guda
biyu ta faɗi inda ba ta iya zuwa ba.

```ring
oP = StzMathFigureQ(:Function, [ :f = "1 / (x - 1)", :on = [ -3, 4 ] ])
? oP.Why()
#--> a function figure: 400 samples in 2 piece(s), 0 mark(s), 1 place(s) not finite
? oP.PieceCount()
#--> 2
```

## 9. A kan duniyarka

Layi ta cikin asali wanda gangarensa shi ne adadin buƙatun da makarantarka ta karɓa a wannan makon. Abin da
yake bugawa ya danganta da duniyar da wannan darasin ke gudana a kanta, don haka shafin ba ya nuna sakamako:
gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
oW = StzMathFigureQ(:Function, [ :f = "" + len(aReq) + " * x", :on = [ -2, 2 ], :mark = [ :zeros ] ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-04-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka bayyana aiki a matsayin siffa, ka karanta inda ya zama sifili da inda ya juya, ka
  duba sifili ta hanyar lissafi, ka karanta tagar da siffar ta zaɓa, ka zana da'ira da fure, ka nemi tangent,
  kuma ka ga siffar ta tsaya a karyewa maimakon zana ta ciki.
- **Dalilin da ya sa yake da muhimmanci:** an lissafa layin kuma an samu alamomin, don haka kowane wuri da
  hoton ya ambata magana ce da za ka iya duba da layi ɗaya na lissafi, kuma wannan babin ya yi haka.
- **Abin da ke zuwa:** sa harafi inda dabarar take, hoton ya zama iyali. Babi na gaba yana motsa harafin ya
  kalli abin da ke motsi tare da shi.
