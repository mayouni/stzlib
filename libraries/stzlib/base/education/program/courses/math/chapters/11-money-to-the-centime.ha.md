# Kuɗi da bai kamata su rasa ko kwabo ɗaya ba

*Lissafi · Babi na 11 · Ƙwarewa CR-02: "Me zai karye idan na yi kuskure?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Kuɗi lissafi ne mai doka a haɗe: wurare biyu, koyaushe, kuma kowace zagayawa an lissafa. Lambar inji ba ta
da irin wannan doka, don haka dubu na kwabo goma da aka ƙara a kanta ba ɗari ba ne, kuma ba a gaya wa kowa
ba. Lambar kuɗi ta Softanza tana ɗauke da dokar: tana zagayawa yadda bankuna suke zagayawa, tana faɗi lokacin
da rabawa ba ta ƙare ba, kuma idan rabo uku ba su koma ga dunƙulen ba, bambancin kwabo ne da za ka iya gani.
Wannan babin yana ƙara, ya raba, ya zagaye kuma ya sa haraji a kan kuɗi, ya karanta kwabon a kowane lokaci.

## 1. Dubu na kwabo goma a kan inji

Ƙara ɗaya cikin goma sau dubu. Inji ya buga ɗari ya ce ba ɗari ba ne.

```ring
n = 0
for i = 1 to 1000
	n += 0.1
next
? n
#--> 100.00
? n = 100
#--> 0
```

## 2. Dubu na kwabo goma a matsayin kuɗi

Lambar kuɗi tana riƙe wurare biyu a kowane mataki. Dubu daga cikinsu suna yin ɗari, daidai, kuma lambar ta
san cewa kuɗi ce.

```ring
oT = StzMoneyQ("0")
for i = 1 to 1000
	oT.Add("0.10")
next
? oT.Content()
#--> 100.00
? oT.Same(100)
#--> 1
? oT.IsMoney()
#--> 1
```

## 3. Raba kuɗi hanyoyi uku

Ɗari da kwabo goma da aka raba uku ba ya ƙarewa. Lambar kuɗi tana tsayawa a wurare biyu, ta ce ba ta yi daidai
ba, kuma ta faɗi dalili.

```ring
oP = StzMoneyQ("100.10")
oP.Divide("3")
? oP.Content()
#--> 33.37
? oP.IsExact()
#--> 0
? oP.WhyNotExact()
#--> the division does not terminate in 8 decimal place(s)
```

## 4. Rabon ba su koma ba

Rabo uku na 33.37 suna yin 100.11: kwabo ya bayyana daga babu. Lambar ta ce kuɗin biyun ba ɗaya ba ne, wanda
shi ne jumlar da littafin lissafi ke buƙata.

```ring
oS = StzMoneyQ("33.37")
oS.MultiplyBy("3")
? oS.Content()
#--> 100.11
? oS.Same("100.10")
#--> 0
```

## 5. Dokar mai lissafi: rabo na ƙarshe yana ɗaukar ragowa

Ba mutane biyu 33.37 na uku kuma abin da ya rage. Rabo ukun sun koma ga dunƙulen, kuma an lissafa kwabon
maimakon ƙirƙira shi.

```ring
oZ = StzMoneyQ("100.10")
oZ.Subtract("33.37")
oZ.Subtract("33.37")
? oZ.Content()
#--> 33.36
? 33.37 + 33.37 + 33.36
#--> 100.10
```

## 6. Zagayawa yadda bankuna suke zagayawa

Rabi yana zuwa ga maƙwabci mai-ma'aurata: 2.675 ya haura zuwa 2.68 kuma 2.665 ya sauka zuwa 2.66. A kan
zagayawa miliyan ɗaya, hawa da sauka suna soke juna, kuma jimlar ba ta karkata.

```ring
? StzMoneyQ("2.675").Content()
#--> 2.68
? StzMoneyQ("2.665").Content()
#--> 2.66
```

## 7. Haraji, zuwa kwabo

Haraji na 19.25 cikin ɗari a kan 100.10 shi ne 19.269 da kwata; a matsayin kuɗi 19.27 ne, kuma lambar tana
riƙe shi a matsayin kuɗi maimakon kaso na ɗaya.

```ring
oV = StzMoneyQ("100.10")
oV.MultiplyBy("0.1925")
? oV.Content()
#--> 19.27
? oV.IsMoney()
#--> 1
```

## 8. Tsarin da yake ƙi

Lamba daidai ta hanyar tsari ba za ta zama kimanta ba: raba ɗaya da uku, ta ƙi, da suna, maimakon ta ba ka
sulusi da aka zagaye.

```ring
oX = StzExactQ("1")
try
	oX.Divide("3")
catch
	? "refused"
done
#--> refused
```

## 9. A kan duniyarka

Kuɗin 2.50 a kan kowace buƙata da makarantarka ta karɓa a wannan makon, a matsayin kuɗi. Abin da yake bugawa
ya danganta da duniyar da wannan darasin ke gudana a kanta, don haka shafin ba ya nuna sakamako: gudanar da
shi.

```ring
aReq = EduWorldObjects("requested")
oFee = StzMoneyQ("2.50")
oFee.MultiplyBy("" + len(aReq))
? EduWorldName()
? oFee.Content()
```

{{exercise:math-11-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka ƙara dubu na kwabo goma a kan inji da a matsayin kuɗi, ka raba kuɗi hanyoyi uku ka
  karanta dalilin da ya sa rabawar ba ta ƙare ba, ka ga rabo uku sun yi kwabo daga babu ka ba rabo na ƙarshe
  ragowa a maimako, ka zagaye rabi yadda bankuna suke zagayawa, ka sa haraji a kan kuɗi zuwa kwabo, kuma ka
  haɗu da tsarin da yake ƙin kimantawa.
- **Dalilin da ya sa yake da muhimmanci:** kwabo da aka rasa a shiru littafin lissafi ne da ba ya daidaita
  kuma babu wanda ya san dalili. Lamba da take ɗauke da dokar ta faɗi abin da ta zagaye littafin lissafi ne da
  ke bayyana kansa.
- **Abin da ke zuwa:** shawara a matsayin samfuri. Babi na gaba yana faɗin abin da za a ƙara zuwa mafi girma
  da abin da za a riƙe ƙasa, ya bar injin ya samu mafi kyawun shiri ya ambaci injin da ya samu shi.
