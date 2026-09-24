# Faɗe shi da harshenka

*Gabatarwa ta Farko · Babi na 4 · Fasaha EX-05: "Zan iya faɗin wannan shirin da harshena ya gudana?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Softanza tana fahimtar shirin da aka rubuta a matsayin jimla, da harsunan ɗan adam fiye da ɗaya. Wannan ba
fassarar shafin ba ce: jimlar da kanta ita ce shirin, kuma tana gudana. Kowane ɗaki a ƙasa yana gudana a
kowane bugu na wannan babin, ko da wane harshe kake karanta shi.

## 1. Harsunan da Softanza take magana yau

```ring
? @@( StzNaturalLanguages() )
#--> [ "en", "ha", "fr", "ar", "tr" ]
```

## 2. Turanci

`Understood()` yana sake faɗin abin da Softanza ta ɗauki jimlar tana nufi, domin ka duba shi kafin ka
amince da sakamakon.

```ring
oN = Naturally("Create a list with [ 4, 4, 9 ] and remove its duplicates")
? @@( oN.Result() )
#--> [ 4, 9 ]
? oN.Understood()
#--> create a list with [ 4, 4, 9 ] -> remove duplicates
```

## 3. Faransanci

```ring
oF = NaturallyIn("fr", "Crée une liste avec [ 4, 4, 9 ] et enlève les doublons")
? @@( oF.Result() )
#--> [ 4, 9 ]
? oF.Understood()
#--> crée liste avec [ 4, 4, 9 ] -> enlève les doublons
```

## 4. Larabci

```ring
oA = NaturallyIn("ar", "أنشئ قائمة مع [ 4, 4, 9 ] أزل التكرارات")
? @@( oA.Result() )
#--> [ 4, 9 ]
? oA.Understood()
#--> أنشئ قائمة بـ [ 4, 4, 9 ] -> أزل التكرارات
```

## 5. Hausa

```ring
oH = NaturallyIn("ha", "Yi jeri dauke [ 4, 4, 9 ] cire maimaitattu")
? @@( oH.Result() )
#--> [ 4, 9 ]
? oH.Understood()
#--> yi jeri dauke [ 4, 4, 9 ] -> cire maimaitattu
```

## 6. Idan ba ta fahimta ba, tana faɗin wace kalma

Softanza ba ta taɓa zato ba. Jimlar da ba za ta iya warwarewa ba ana ruwaito ta kalma bayan kalma, tare da
kalma mafi kusa da ta sani.

```ring
? @@( StzNaturalLintIn("fr", "Crée une liste avec [ 4, 4, 9 ] et danse la salsa") )
#--> [ [ "understood", 0 ], [ "unresolved", [ [ "danse", "" ], [ "salsa", "sans" ] ] ] ]
```

{{exercise:ex-04-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka gudanar da shiri ɗaya a matsayin jimla da harsuna huɗu, ka sake karanta abin da
  aka fahimta, ka ga an ƙi jimla kalma bayan kalma maimakon a yi zato.
- **Me ya sa yake da muhimmanci:** harshen farko na mai koyo harshen shirye-shirye ne a nan. Babu abin da
  ke ɓacewa tsakanin yadda kake tunani da yadda kake rubutu.
- **Abin da ke tafe:** tambayoyi uku na babi na 1, an yi wa rubutu, jeri, da kowane abu.
