# Siffofi a cikin rubutu

*Gabatarwa ta Farko · Babi na 8 · Fasaha PA-01: "Menene siffar rubutun da nake nema?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Babi na 7 ya miƙa sharaɗi a kan lambobi. Rubutu ma yana da sharuɗɗa, amma nasa game da **siffa** ne:
lambobi huɗu, ɗan sanda, lambobi biyu. Siffa tana rubuta wannan siffar, kuma `rx()` yana gwada kowane
rubutu a kanta. Karanta siffa daga hagu zuwa dama, guntu bayan guntu, kuma tana faɗin abin da take dacewa.

## 1. Kwanan wata yana da siffa

`[0-9]` lamba ɗaya ce; `{4}` yana cewa huɗu daga cikinta. Karanta dukan siffar kamar *lambobi huɗu, ɗan
sanda, lambobi biyu, ɗan sanda, lambobi biyu*.

```ring
? rx("[0-9]{4}-[0-9]{2}-[0-9]{2}").Match("2026-09-24")
#--> TRUE
? rx("[0-9]{4}-[0-9]{2}-[0-9]{2}").Match("24/09/2026")
#--> FALSE
```

## 2. Wani wuri a cikin rubutun, ko dukan rubutun

`Match` yana tambaya ko dukan rubutun yana da siffar. `MatchFirst` yana tambaya ko siffar ta bayyana a wani
wuri.

```ring
? rx("[0-9]+").Match("24/09/2026")
#--> FALSE
? rx("[0-9]+").MatchFirst("24/09/2026")
#--> TRUE
? @@( Q("tea 12, rice 30").Numbers() )
#--> [ "12", "30" ]
```

## 3. Lambar waya a Nijar

`^` da `$` suna kafa siffar a farko da ƙarshe, kuma `\+` yana nufin alamar ƙari ta gaske.

```ring
cPhone = "^\+227 [0-9]{2} [0-9]{2} [0-9]{2} [0-9]{2}$"
? rx(cPhone).Match("+227 90 12 34 56")
#--> TRUE
? rx(cPhone).Match("90 12 34 56")
#--> FALSE
```

## 4. Kalmar da aka faɗa sau biyu

Siffa na iya sa wa guntun abin da ta gani suna ta sake neman sa. `(?P<word>\w+)` yana tuna kalma, kuma
`(?P=word)` yana buƙatar kalma ɗaya.

```ring
cTwice = "\b(?P<word>\w+)[\s]*(?P=word)\b"
? rx(cTwice).Match("the the")
#--> TRUE
? rx(cTwice).Match("the that")
#--> FALSE
```

Softanza kuma tana da mai ginawa da yake rubuta siffofi daga kalmomi, `stzRegexMaker`. Ba a nuna shi a
wannan bugun darasin ba, domin a kan ginin da aka duba darasin a kai, misalansa ba sa gudana.

{{exercise:ex-08-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka karanta siffofi huɗu guntu bayan guntu, ka bambanta dacewar dukan rubutu da dacewa
  a wani wuri, ka kafa siffa a ƙarshe biyu, ka roƙi siffa ta tuna kalma.
- **Me ya sa yake da muhimmanci:** siffa sharaɗi ce a kan siffar rubutu. Da zarar ka iya karanta ɗaya,
  kwanan wata, lambar waya ko farashi sun daina zama "wani rubutu" su zama siffar da za ka iya dubawa.
- **Abin da ke tafe:** jeri da lambobi suna da siffofi su ma.
