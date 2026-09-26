# Ɗerivative da take duba dabara

*Lissafi · Babi na 14 · Ƙwarewa CR-02: "Me zai karye idan na yi kuskure?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Ɗerivative gangaren layi ne a wuri ɗaya: yadda ƙima take canzawa da sauri lokacin da shigarwa ta motsa
kaɗan. Makarantu suna koyar da ita a matsayin dabara da za a samo da hannu, kuma ɗerivative da aka rubuta da
hannu na iya zama kuskure. Injin yana lissafa ɗerivative na kowane bayani da ya tara, daidai, ta hanyar
tafiya a kan tef na bayanin kansa, don haka dabarar da aka rubuta da hannu ta zama magana da tef zai iya
duba. Wannan babin yana tara aiki, ya karanta ɗerivative ɗinsa daga tef, ya duba dabara mai kyau ya kama
mara kyau, kuma ya tabbatar da alamomin babi na 4 da gangare.

## 1. Tara aiki

Aiki bayani ne a kan masu canzawa masu suna, an tara shi sau ɗaya a kan tef na injin. Tambayi ƙimarsa a wuri.

```ring
oF = new stzMathFunction("x^3 - 2*x", [ "x" ])
? oF.ValueAt([ 2 ])
#--> 4
```

## 2. Ɗerivative, daga tef

Ɗerivative a biyu goma ne. Ba a samo kome da hannu ba: tef yana ɗauke da yadda kowane kumburi ke canzawa da
x, kuma injin ya karanta gangaren.

```ring
? oF.DerivativeAt("x", [ 2 ])
#--> 10
```

## 3. Dabarar hannu, an duba

Ɗerivative na littafi ga x kubu debe biyu x shi ne uku x murabba'i debe biyu. A biyu yana ba da goma, kuma
tef ya yarda. Dabarar magana ce; yanzu an duba ta.

```ring
? 3 * 2 * 2 - 2
#--> 10
? fabs( (3 * 2 * 2 - 2) - oF.DerivativeAt("x", [ 2 ]) ) < 0.000001
#--> 1
```

## 4. Dabara mara kyau, an kama

Rubuta ɗerivative a matsayin uku x murabba'i debe ɗaya, kuskuren hannu da ya gaji. A biyu yana ba da goma
sha ɗaya, kuma tef ya ce a'a.

```ring
? 3 * 2 * 2 - 1
#--> 11
? fabs( (3 * 2 * 2 - 1) - oF.DerivativeAt("x", [ 2 ]) ) < 0.000001
#--> 0
```

## 5. Shaida na uku: bambanci mai iyaka

Motsa kaɗan zuwa kowane gefe na biyu ka raba canjin ƙima da canjin shigarwa. Wannan gangare ne da aka auna,
ba da aka samo ba, kuma ya yarda da tef zuwa ɗaya cikin miliyan.

```ring
h = 0.0001
nSlope = ( oF.ValueAt([ 2 + h ]) - oF.ValueAt([ 2 - h ]) ) / ( 2 * h )
? nSlope
#--> 10.00
? fabs( nSlope - 10 ) < 0.000001
#--> 1
```

## 6. Masu canzawa biyu, gradient ɗaya

Da masu canzawa biyu ɗerivative biyu ne, gangare ɗaya ga kowane mai canzawa. Ga x y ƙari y murabba'i a biyu
da uku, gangaren tare da x uku ne kuma tare da y takwas.

```ring
oG = new stzMathFunction("x*y + y^2", [ "x", "y" ])
? oG.ValueAt([ 2, 3 ])
#--> 15
? @@( oG.GradientAt([ 2, 3 ]) )
#--> [ 3, 8 ]
```

## 7. Gangaren sin a sifili

Ɗerivative na sin kosin ne. A sifili tef ya ce ɗaya, kuma kosin na sifili na Ring ya ce ɗaya.

```ring
oS = new stzMathFunction("sin(x)", [ "x" ])
? oS.DerivativeAt("x", [ 0 ])
#--> 1
? fabs( oS.DerivativeAt("x", [ 0 ]) - cos(0) ) < 0.000000001
#--> 1
```

## 8. Alamomin babi na 4, an tabbatar da gangare

Babi na 4 ya samu ƙololuwar x murabba'i debe biyu a sifili ta hanyar kallon layin yana juyawa. Gangaren a can
sifili ne, wanda shi ne ma'anar ƙololuwa, kuma a sifili gangaren sau biyu na tushen murabba'i na biyu ne.

```ring
oQ = new stzMathFunction("x^2 - 2", [ "x" ])
? oQ.DerivativeAt("x", [ 0 ])
#--> 0
? oQ.DerivativeAt("x", [ 1.41421356 ])
#--> 2.83
```

{{exercise:math-14-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka tara aiki a kan tef, ka karanta ɗerivative ɗinsa a wuri, ka duba dabarar da aka
  rubuta da hannu a kanta ka kama mara kyau, ka auna gangaren da bambanci mai iyaka a matsayin shaida na uku,
  ka karanta gradient na masu canzawa biyu, kuma ka tabbatar da alamomin babi na 4 da gangare.
- **Dalilin da ya sa yake da muhimmanci:** dabarar da aka samo da hannu magana ce. Tef yana lissafa gangare
  ɗaya ta wata hanya, don haka an duba maganar da wani abu da bai san dabarar ba.
- **Abin da ke zuwa:** dubawa da ba za ta iya kasawa ba ba dubawa ba ce. Babi na ƙarshe yana bambanta dubawa
  ta kai da dubawa mai zaman kanta, ya nuna dalilin da ya sa kowane tabbatacce yake buƙatar mara tabbaci a
  gefensa.
