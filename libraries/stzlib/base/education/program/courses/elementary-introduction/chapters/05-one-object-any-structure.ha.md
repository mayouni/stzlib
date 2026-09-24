# Abu ɗaya, kowane tsari

*Gabatarwa ta Farko · Babi na 5 · Fasaha FO-03: "Shin wannan tambayar da na yi wa jeri ce, yanzu na yi wa rubutu?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Babi na 1 ya yi wa jeri tambayoyi uku: yana ɗauke, nawa, kuma ina. Wannan babin yana yi wa rubutu tambayoyi
uku ɗin nan, da kalmomi iri ɗaya. Tsarin yana canzawa; tunanin ba ya canzawa.

## 1. Tambayoyi uku, an yi wa rubutu

```ring
oS = new stzString("tea rice tea fish")
? oS.Contains("tea")
#--> TRUE
? oS.NumberOfOccurrence("tea")
#--> 2
? @@( oS.FindAll("tea") )
#--> [ 1, 10 ]
```

## 2. Tambayoyi uku ɗin nan, an yi wa jeri

```ring
oL = new stzList([ "tea", "rice", "tea", "fish" ])
? oL.Contains("tea")
#--> TRUE
? oL.NumberOfOccurrence("tea")
#--> 2
? @@( oL.FindAll("tea") )
#--> [ 1, 3 ]
```

## 3. Kalmomi iri ɗaya, ma'auni daban

Wuri a cikin rubutu yana ƙidaya haruffa; wuri a cikin jeri yana ƙidaya abubuwa. Tambayar ɗaya ce, ma'aunin
ba ɗaya ba ne.

```ring
? StzLen("tea rice tea fish")
#--> 17
? oL.NumberOfItems()
#--> 4
```

## 4. Aiki ɗaya ga duka biyun

`StzFind` yana ɗaukar abin da kake nema da farko, sannan duk inda kake nemansa.

```ring
? @@( StzFind("tea", "tea rice tea fish") )
#--> [ 1, 10 ]
? @@( StzFind("tea", [ "tea", "rice", "tea", "fish" ]) )
#--> [ 1, 3 ]
```

## 5. Aiwatar ta hanya ɗaya, ka karanta sakamakon da kyau

Cire kalma daga rubutu yana barin sararin da ya kewaye ta. Cire abu daga jeri ba ya barin komai a baya.
Aikatau ɗaya, bambanci na gaskiya.

```ring
? @@( oS.Removed("tea") )
#--> " rice  fish"
oL.RemoveAll("tea")
? @@( oL.Content() )
#--> [ "rice", "fish" ]
```

## 6. Wurin aikinka, ta hanyoyi biyu

Abin da aka fi buƙata a wurin aikinka, an ƙidaya shi a cikin jerin buƙatu da kuma a cikin buƙatun da aka
haɗa cikin jimla ɗaya. Ka gudanar da shi: amsar ta dogara da duniyar.

```ring
aReq = EduWorldObjects("requested")
? StzListQ(aReq).NumberOfOccurrence(aReq[1])
? Q( Q(aReq).Joined(" ") ).NumberOfOccurrence(aReq[1])
```

{{exercise:ex-05-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka tambayi "yana ɗauke", "nawa" da "ina" ga rubutu da jeri da kalmomi iri ɗaya, ka
  ga inda amsoshin suka bambanta a ma'auni da kuma abin da cirewa ke barin a baya.
- **Me ya sa yake da muhimmanci:** hanyar tunani ɗaya tana ɗaukar kowane tsari. Idan tebur ko zane ya zo,
  ka riga ka san tambayoyin.
- **Abin da ke tafe:** motsi huɗu da kowane shiri ya ƙunsa: tafiya, tambaya, samarwa, aiki.
