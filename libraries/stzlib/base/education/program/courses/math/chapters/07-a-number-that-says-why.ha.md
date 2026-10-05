# Lamba da take faɗin dalilin da ya sa ba ta zama daidai ba

*Lissafi · Babi na 7 · Ƙwarewa CR-03: "Me ya sa ya ce a'a?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Lambar inji akwati ce mai tsayayyen girma, kuma ƙimar da ba ta shiga ana zagaye ta don ta shiga, a shiru.
Ɗaya cikin goma ba ya shiga. Lambar Softanza ta bambanta ta hanya ɗaya da ke canza kome: ta san ko ta yi
daidai, kuma idan ba ta yi ba, za ta iya faɗin abin da aka rasa da inda. Wannan babin yana haɗuwa da lambar
inji da farko, sannan da lamba daidai, kuma ya bar ta daidai ta bayyana kanta.

## 1. Lambar inji, an kama ta

Ƙara ɗaya cikin goma da biyu cikin goma a kan inji ka tambaya ko sakamakon uku cikin goma ne. Inji ya ce a'a,
kuma ya buga ƙima da take kama da e. Amsoshi biyun sun fito daga zagayawa ɗaya.

```ring
? 0.1 + 0.2 = 0.3
#--> 0
? 0.1 + 0.2
#--> 0.30
```

## 2. Lamba daidai

Ba da lambobin a matsayin rubutu, ɗakin karatu zai riƙe su a matsayin lambobin goma. Jimlar uku cikin goma
ce, daidai, kuma lambar tana faɗin wane wakilci take ɗauke da shi.

```ring
oS = StzNumberQ("0.1")
oS.Add("0.2")
? oS.Content()
#--> 0.3
? oS.IsExact()
#--> 1
? oS.Representation()
#--> decimal
```

## 3. Daidai a matsayin lambobi, ba a matsayin rubutu ba

Uku cikin goma da talatin cikin ɗari lamba ɗaya ce da rubutu daban. Lamba daidai tana kwatanta a matsayin
lamba; alamar daidai ta Ring tana kwatanta rubutun.

```ring
? oS.Same("0.30")
#--> 1
? "0.3" = "0.30"
#--> 0
```

## 4. Rabawa da ba za ta iya ƙarewa ba

Ɗaya an raba da uku ba ya ƙarewa. Lambar tana tsayawa a wurare shida, ta ce ba ta yi daidai ba, kuma ta faɗi
dalili.

```ring
oT = StzNumberQ("1")
oT.Divide("3")
? oT.Content()
#--> 0.333333
? oT.IsExact()
#--> 0
? oT.WhyNotExact()
#--> the division does not terminate in 6 decimal place(s)
```

## 5. Riƙe shi a matsayin kaso, ba abin da ya ɓace

An rubuta ɗaya bisa uku, lambar rational ce kuma daidai. Ƙara sulusi biyu, sakamakon ɗaya ne, kuma lambar ta
ce ita ɗaya ce da ɗaya.

```ring
oQ = StzNumberQ("1/3")
? oQ.Representation()
#--> rational
? oQ.IsExact()
#--> 1
oQ.Add("2/3")
? oQ.Content()
#--> 1
? oQ.Same(1)
#--> 1
```

## 6. Bayan mafi girman lamba mara-ma'aurata ta inji

Lambar inji ba za ta iya riƙe kowane cikakken lamba sama da miliyan tara na biliyan ba: ƙara ɗaya ga lamba
mara-ma'aurata a can, ta sauka a kan mai-ma'aurata. Babban cikakken lamba na ɗakin karatu yana riƙe ta.

```ring
oB = StzNumberQ("9007199254740993")
? oB.Representation()
#--> biginteger
oB.Add(1)
? oB.Content()
#--> 9007199254740994
? 9007199254740993 + 1
#--> 9007199254740992.00
```

## 7. Uku cikin goma, hanyoyi uku

Ɗaya cikin goma sau uku uku cikin goma ne ga lamba daidai, kuma ba ga inji ba.

```ring
oM = StzNumberQ("0.1")
oM.MultiplyBy("3")
? oM.Content()
#--> 0.3
? oM.IsExact()
#--> 1
? 0.1 * 3 = 0.3
#--> 0
```

## 8. A kan duniyarka

Rabon takardun sakamako cikin buƙatun makarantarka, a matsayin rabawa daidai: lambar tana faɗin ko rabon ya
ƙare, kuma me ya sa ba haka ba idan bai ƙare ba. Abin da yake bugawa ya danganta da duniyar da wannan darasin
ke gudana a kanta, don haka shafin ba ya nuna sakamako: gudanar da shi.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
oW = StzNumberQ("" + nT)
oW.Divide("" + len(aReq))
? EduWorldName()
? oW.Content()
? oW.IsExact()
? oW.WhyNotExact()
```

{{exercise:math-07-01}}

## Taƙaitawa

- **Abin da ka cim ma:** ka kama lambar inji tana zagaye ɗaya cikin goma, ka ƙara goma ɗaya daidai, ka
  kwatanta lambobi a matsayin lambobi, ka raba ɗaya da uku ka karanta dalilin da ya sa sakamakon bai yi daidai
  ba, ka riƙe sulusi a matsayin kaso ba tare da rasa kome ba, kuma ka wuce mafi girman lamba mara-ma'aurata ta
  inji.
- **Dalilin da ya sa yake da muhimmanci:** lamba da take faɗin dalilin da ya sa ba ta zama daidai ba tana
  mayar da zagayawa a shiru zuwa jumla da za ka iya karantawa. Kuɗi, a wani babi mai zuwa, shi ne inda wannan
  jumlar take kashe kwabo idan ta ɓace.
- **Abin da ke zuwa:** matirisai a matsayin hotuna. Babi na gaba yana zana ninkawa a matsayin ragogi uku ya
  duba tantani ɗaya nata da hannu.
