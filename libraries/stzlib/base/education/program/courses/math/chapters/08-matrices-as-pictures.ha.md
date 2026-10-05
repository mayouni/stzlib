# Matirisai a matsayin hotuna

*Lissafi · Babi na 8 · Ƙwarewa PA-04: "Waɗanne tantani ne suke amsa tambayata?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Matirisa raga ce ta lambobi, kuma ninkawar matirisai biyu raga ce da kowane tantaninta layi ne na farko da ya
haɗu da ginshiƙi na biyu. Idan aka faɗe ta a matsayin hoto, ninkawa ragogi uku ne gefe da gefe, da layi,
ginshiƙi da tantanin da suka yi a haskake tare. Wannan babin yana bayyana matirisai a matsayin siffofi, ya
karanta tantani daga siffar, ya duba tantanin ninkawa da hannu, kuma ya nemi siffar ta ƙi abin da ba za a
iya ninkawa ba.

## 1. Raga ɗaya

Ana bayyana siffar matirisa da layukanta. Siffar tana ƙidaya tantaninta ta sanya musu suna da harafin raga,
layi da ginshiƙi: raga ta farko a ce, layinta na biyu da ginshiƙinta na farko a2_1 ne.

```ring
oA = StzMathFigureQ(:Matrix, [ :of = [ [ 1, 2 ], [ 3, 4 ] ], :label = "A" ])
? oA.Why()
#--> a matrix figure: A (2 x 2), 4 cells
? oA.Fact(:datum, [ "a2_1", "v" ])[:message]
#--> a2_1 carries v = 3
```

## 2. Ninkawa, a matsayin ragogi uku

Bayyana ninkawa, siffar za ta zana A, B da A sau B, ta lissafa kowane tantani na sakamakon, kuma ta haskaka
layin da ginshiƙin da suka yi tantanin da ka nemi gani.

```ring
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 2, 7, 1, 8 ], [ 2, 8, 1, 8 ], [ 2, 8, 4, 5 ] ],
                                            [ [ 1, 0 ], [ 0, 1 ], [ 2, 3 ], [ 1, 1 ] ] ], :show = [ 2, 1 ] ])
? oP.Why()
#--> a matrix figure: A (3 x 4) . B (4 x 2) = A . B (3 x 2), 26 cells
```

## 3. Hoton yana yi wa kansa hukunci

Siffar matirisa tana da dokoki uku: tantanin ninkawa shi ne ninkawar ɗigo ta layinsa da ginshiƙinsa, girma
sun yarda, kuma kowace raga tana riƙe tantaninta. Siffar tana duba su a kan hotonta.

```ring
? len( oP.Violations() )
#--> 0
```

## 4. Tantanin ninkawa, an duba da hannu

Tantanin da aka haskaka shi ne layi na 2 na A da ya haɗu da ginshiƙi na 1 na B. Karanta shi daga siffar,
sannan ka lissafa shi da kanka: biyu sau ɗaya, ƙari takwas sau sifili, ƙari ɗaya sau biyu, ƙari takwas sau
ɗaya.

```ring
? oP.Fact(:datum, [ "c2_1", "v" ])[:message]
#--> c2_1 carries v = 12
? 2 * 1 + 8 * 0 + 1 * 2 + 8 * 1
#--> 12
```

## 5. Abin da ba za a iya ninkawa ba

Layi na A dole ne ya yi tsawon ginshiƙi na B. Ninkawar da ta karya wannan ana ƙin ta da suna, da lambobi
biyun da ba su yarda ba.

```ring
try
	StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ] ], [ [ 1, 2 ] ] ] ])
catch
	? "refused"
done
#--> refused
```

## 6. Lambobi a matsayin launi

Idan aka nemi ta nuna matirisa a matsayin zafi, siffar tana launin kowane tantani a kan gangara ɗaya daga
mafi ƙanƙantar ƙimarta zuwa mafi girma. Matsayin gangaren lamba ce da siffar ke ɗauke da ita: mafi girman
ƙima tana a ɗaya.

```ring
oH = StzMathFigureQ(:Matrix, [ :of = [ [ 4, 1, 0 ], [ 1, 4, 1 ], [ 0, 1, 4 ] ], :as = :heat, :label = "A" ])
? oH.Why()
#--> a matrix figure: A (3 x 3), 9 cells on one ramp
? oH.Fact(:datum, [ "a2_2", "t" ])[:message]
#--> a2_2 carries t = 1
```

## 7. A kan duniyarka

Layi ɗaya: buƙatu nawa na kowane iri makarantarka ta karɓa a wannan makon, an zana a matsayin matirisa. Abin
da yake bugawa ya danganta da duniyar da wannan darasin ke gudana a kanta, don haka shafin ba ya nuna
sakamako: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
aRow = []
for i = 1 to len(aKinds)
	aRow + StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
oW = StzMathFigureQ(:Matrix, [ :of = [ aRow ], :label = "requests by kind" ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-08-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka bayyana matirisa a matsayin siffa, ka karanta tantani da sunansa, ka bayyana
  ninkawa ka ga ragoginta uku, ka duba tantanin ninkawa da hannu da ƙimar siffar kanta, ka ga an ƙi ninkawa
  saboda girmanta, kuma ka launa matirisa a kan gangara ɗaya.
- **Dalilin da ya sa yake da muhimmanci:** ninkawa tantani ashirin da shida ne da doka ɗaya. Siffar tana
  lissafa kowane tantani kuma tana ɗauke da dokar, don haka tantani ɗaya da ka duba da hannu yana tsaya wa
  dukkansu.
- **Abin da ke zuwa:** ƴan lambobi, da kalmomin da suke taƙaita su. Babi na gaba yana zana akwati ya karanta
  matsakaici, kwata da ƙimomin da suka fita daga hoton.
