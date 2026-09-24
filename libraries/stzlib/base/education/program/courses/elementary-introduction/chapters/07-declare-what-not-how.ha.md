# Bayyana me, ba yadda ba

*Gabatarwa ta Farko · Babi na 7 · Fasahohi FO-04 "Zan iya faɗin abin da nake so in bar injin ya yanke yadda?" da PA-03 "Zan iya miƙa sharaɗin maimakon in rubuta reshen?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Har zuwa yanzu kana sa wa abu tabbatacce suna: "tea", maimaitattu, wuri na 4. Wannan babin yana sa wa
**sharaɗi** suna, ya miƙa shi a matsayin bayanai. Kai kana faɗin *abin da* ya cancanta; injin yana yanke
*yadda* zai bi jerin, ya gwada kowane abu ya tattara amsar. `W` a ƙarshen suna yana nufin *where*, "inda".

## 1. Nemo inda sharaɗi yake gaskiya

`@item` yana tsaya wa kowane abu bi da bi. Sharaɗin ɗan rubutu ne tsakanin manyan baka.

```ring
o = new stzList([ 4, 7, 10, 3, 8 ])
? @@( o.FindW("{ @item > 5 }") )
#--> [ 2, 3, 5 ]
? @@( o.ItemsW("{ @item > 5 }") )
#--> [ 7, 10, 8 ]
? o.CountW("{ @item > 5 }")
#--> 3
```

## 2. Kowace tambaya na iya zama sharaɗin

```ring
? @@( o.FindW("{ IsEven(@item) }") )
#--> [ 1, 3, 5 ]
? o.CheckW("{ isNumber(@item) }")
#--> TRUE
```

## 3. Doka bayanai ce: ajiye ta, ka yi amfani da ita a ko'ina

Dokar tana zaune a cikin canji. Jerin biyu, doka ɗaya, kuma dokar ba ta taɓa sanin wane jeri za ta haɗu da
shi ba.

```ring
cRule = "{ @item > 20 }"
oA = new stzList([ 12, 0, 30, -5, 18, 25 ])
oB = new stzList([ 3, 40, 9 ])
? oA.CountW(cRule)
#--> 2
? oB.CountW(cRule)
#--> 1
```

## 4. Aiwatar inda dokar take gaskiya

```ring
? @@( oA.ItemsW(cRule) )
#--> [ 30, 25 ]
oA.RemoveW(cRule)
? @@( oA.Content() )
#--> [ 12, 0, -5, 18 ]
```

## 5. Kalma ɗaya a kan kalmomi

```ring
oS = new stzList([ "ring", "PHP", "C#", "ruby", "GO" ])
? @@( oS.FindW("{ IsUppercase(@item) }") )
#--> [ 2, 3, 5 ]
? @@( oS.ItemsW("{ Q(@item).IsLowercase() }") )
#--> [ "ring", "ruby" ]
```

{{exercise:ex-07-01}}

{{exercise:ex-07-02}}

## Taƙaitawa

- **Abin da ka cimma:** ka nemo, ka ƙidaya, ka riƙe ka cire abubuwa bisa sharaɗin da ka rubuta sau ɗaya
  a matsayin rubutu, ka yi amfani da doka ɗaya a kan jeri biyu ba tare da canza ta ba.
- **Me ya sa yake da muhimmanci:** sharaɗin da yake bayanai ana iya ajiye shi a fayil, a aika wa abokin
  aiki, a yi amfani da shi a kan bayanan da ba su wanzu ba lokacin da aka rubuta shi. Reshe a cikin madauki
  ba zai iya ko ɗaya daga cikin waɗannan ba.
- **Abin da ke tafe:** sharuɗɗa a kan rubutu suna da harshensu, kuma ana kiransa siffa.
