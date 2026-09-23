# Nemo, sannan ka aiwatar

*Gabatarwa ta Farko · Babi na 1 · Fasaha EX-03: "Ina yake, kuma me zan yi a can?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Kowane wurin aiki yana karɓar buƙatu: gidan abinci yana karɓar oda, banki yana karɓar tikiti, kuma buƙata ɗaya
takan zo fiye da sau ɗaya. Wannan babin yana maganin buƙatun da aka maimaita ta hanyar Softanza. Da farko ka zaɓi
abin. Sannan ka tambaya ko yana ɗauke da abin da kake nema, ka ƙidaya shi, ka nemo shi. Sai bayan haka ka aiwatar.

## 1. Zaɓi abin

Jerin buƙatu `stzList` ne.

```ring
o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])
? o1.NumberOfItems()
#--> 6
```

## 2. Yi tambayar "ko yana ɗauke"

Kafin ka aiwatar, ka tambaya ko akwai abin da za a yi wa aiki.

```ring
? o1.ContainsDuplicates()
#--> TRUE
```

## 3. Yi tambayar "guda nawa"

```ring
? o1.NumberOfDuplicates()
#--> 3
```

## 4. Tambayi wurare

```ring
? @@( o1.FindDuplicates() )
#--> [ 3, 5, 6 ]
```

## 5. Aiwatar a wuraren

Ka san inda buƙatun da aka maimaita suke, don haka za ka iya cire su.

```ring
o1.RemoveItemsAtPositions( o1.FindDuplicates() )
? @@( o1.Content() )
#--> [ "tea", "rice", "fish" ]
```

Softanza kuma tana da kalma ɗaya don dukan aikin. Karanta ta kamar jimla: *jerin, an cire maimaitattu*.

```ring
? @@( StzListQ([ "tea", "rice", "tea" ]).DuplicatesRemoved() )
#--> [ "tea", "rice" ]
```

## 6. Tambayoyi iri ɗaya, a wurin aikinka

Wannan ɗakin yana karanta buƙatun da wurin aikinka ya karɓa yau. Abin da yake bugawa ya dogara da duniyar da wannan
darasi yake gudana a kai, don haka shafin ba ya nuna sakamako ko kaɗan: ka gudanar da shi.

```ring
o2 = new stzList( EduWorldObjects("requested") )
? EduWorldName()
? o2.ContainsDuplicates()
? o2.NumberOfDuplicates()
? @@( o2.DuplicatesRemoved() )
```

## 7. Faɗe shi da kalmominka

Softanza tana fahimtar buƙata ɗaya idan an rubuta ta da Hausa.

```ring
? @@( NaturallyIn("ha", "Yi jeri dauke [ 5, 3, 5, 1 ] cire maimaitattu").Result() )
#--> [ 5, 3, 1 ]
```

{{exercise:ex-01-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka bi da jeri ta tsarin tunani. Ka zaɓe shi, ka tambaya ko yana da maimaitattu, ka ƙidaya su
  ka nemo su, sannan ka cire su.
- **Me ya sa yake da muhimmanci:** aiwatarwa tana zuwa a ƙarshe. Kowace tambaya da ka fara yi tana sa aikin ya zama
  daidai, kuma ana iya tabbatar da kowace amsa.
- **Abin da ke tafe:** tambayoyi biyar ɗin nan suna aiki a kan rubutu, teburi da zane-zanen alaƙa. Babi na gaba
  yana yi wa rubutu su.
