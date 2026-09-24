# Jimla ta farko

*Gabatarwa ta Farko · Babi na 2 · Fasahohi FO-01 "Me nake tambaya da gaske?" da EX-01 "Wane abu ne ya riƙe bayanaina?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

A babi na 1 buƙatun sun zo a matsayin jeri. Yau suna zuwa a matsayin jimla: ƙorafin abokin ciniki. Kafin
kowace lamba, tsarin tunani yana roƙonka ka faɗi matsalar da kalmomi ka fitar da manyan kalmominta, domin
manyan kalmomin ne suke sunan abin da za ka zaɓa.

## 1. Faɗi matsalar

*"Shin wannan ƙorafin yana maimaita kalma, kuma wacce?"*

Manyan kalmomi uku. **Ƙorafi** rubutu ne, saboda haka abin `stzString` ne. **Kalma** abu ne da rubutu zai
iya ba ka. **Maimaitawa** tambaya ce game da maimaitattu, kuma maimaitattu suna zaune a cikin jeri.

## 2. Zaɓi abin

```ring
o1 = new stzString("the bread was cold and the tea was cold")
? o1.NumberOfWords()
#--> 9
```

## 3. Tambayi rubutun kalmominsa

```ring
? @@( o1.Words() )
#--> [ "the", "bread", "was", "cold", "and", "the", "tea", "was", "cold" ]
```

## 4. Babbar kalmar "maimaitawa" ta jeri ce

Kalmomin jeri ne yanzu, saboda haka tambayoyin babi na 1 suna aiki a kansu ba tare da canji ba.

```ring
oW = new stzList( o1.Words() )
? oW.ContainsDuplicates()
#--> TRUE
? oW.NumberOfDuplicates()
#--> 3
```

## 5. Nemo, sannan ka aiwatar

```ring
? @@( oW.FindDuplicates() )
#--> [ 6, 8, 9 ]
? @@( oW.DuplicatesRemoved() )
#--> [ "the", "bread", "was", "cold", "and", "tea" ]
```

## 6. Wurin aikinka, a matsayin jimla

Buƙatun da wurin aikinka ya karɓa yau, an haɗa su cikin jimla ɗaya. Abin da yake bugawa ya dogara da
duniyar da wannan darasi yake gudana a kai: ka gudanar da ɗakin.

```ring
aReq = EduWorldObjects("requested")
? Q(aReq).Joined(", ")
? Q( Q(aReq).Joined(" ") ).NumberOfWords()
```

{{exercise:ex-02-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka faɗi matsala da kalmomi, ka ɗauki manyan kalmominta, ka bar su su zaɓi abin:
  rubutu ga ƙorafin, jeri ga kalmomin da aka maimaita.
- **Me ya sa yake da muhimmanci:** abin da ka zaɓa yana yanke tambayoyin da za ka iya yi. Rubutu yana
  amsa "kalmomi nawa"; jeri yana amsa "waɗanne aka maimaita".
- **Abin da ke tafe:** sunayen tambayoyin da kansu jimloli ne. Babi na gaba yana koya maka karanta su.
