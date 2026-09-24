# Karanta sunan kamar jimla

*Gabatarwa ta Farko · Babi na 3 · Fasaha EX-04: "Shin wannan sunan yana canza abin, yana ba ni kwafi, ko yana ci gaba da jimlar?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Sunan hanya na Softanza jimla ce da aka yi wa abu. Nahawunsa yana faɗa maka abin da zai faru kafin ka gudanar
da shi. Wannan babin yana koyar da sigogi uku da za ka haɗu da su a kowane shafi: siga ta aiki, siga ta abin
da aka yi, da siga mai gudana.

## 1. Sigar aiki tana canza abin

`RemoveAll` umarni ne. Abin yana bi, kuma an canza shi.

```ring
o1 = new stzString("RIxxNxG")
o1.RemoveAll("x")
? o1.Content()
#--> RING
```

## 2. Sigar abin da aka yi tana ba ka kwafi

`Removed` siga ce ta abin da ya wuce: *rubutun, an cire x*. Tana amsawa da sabuwar daraja ta bar abin kamar
yadda yake.

```ring
o1 = new stzString("RIxxNxG")
? o1.Removed("x")
#--> RING
? o1.Content()
#--> RIxxNxG
```

## 3. Siga mai gudana tana ci gaba da jimlar

`Q` a ƙarshen suna yana nufin *sannan*. Jimlar tana ci gaba har sai sigar abin da aka yi ta rufe ta.

```ring
? Q("rixxnxg").RemoveQ("x").UppercaseQ().Spacified()
#--> R I N G
```

## 4. Jimla mai gudana a kan abu tana canza shi

```ring
o1 = new stzString("rixxnxg")
? o1.RemoveQ("x").Uppercased()
#--> RING
? o1.Content()
#--> ring
```

## 5. Faɗi "a kan kwafi" da QC

`QC` yana nufin *sannan, a kan kwafi*. Ba a taɓa na asali ba.

```ring
o1 = new stzString("rixxnxg")
? o1.RemoveQC("x").Uppercased()
#--> RING
? o1.Content()
#--> rixxnxg
```

## 6. Sigar da aka sa wa suna tana karantuwa kamar magana

```ring
? Q("tea, rice, tea").Replaced("tea", :With = "coffee")
#--> coffee, rice, coffee
```

## 7. Tambaya suna ne da yake farawa da Is

```ring
? Q("bread").IsLowercase()
#--> TRUE
```

{{exercise:ex-03-01}}

## Taƙaitawa

- **Abin da ka cimma:** kana iya faɗa, daga sunan kaɗai, ko yana canza abin (`RemoveAll`), yana amsawa da
  kwafi (`Removed`), ko yana ci gaba da jimlar (`RemoveQ`, da `RemoveQC` a kan kwafi).
- **Me ya sa yake da muhimmanci:** ba ka taɓa buƙatar gudanar da hanya don ka san ko bayananka za su
  tsira ba. Sunan yana faɗa.
- **Abin da ke tafe:** jimla ɗaya, an faɗe ta da Faransanci, Larabci ko Hausa.
