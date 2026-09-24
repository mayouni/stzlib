# Siffofi a cikin tsari

*Gabatarwa ta Farko · Babi na 9 · Fasaha PA-02: "Menene siffar wannan jerin ko waɗannan lambobin?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Jeri yana da siffa: lamba, sannan rubutu. Lamba tana da siffa: lambobi huɗu, ko firamare, ko ninkin biyar.
Softanza tana rubuta waɗannan siffofin a matsayin siffofi su ma, da `Lx()` ga jeri da `stzNumbrex` ga
lambobi, kuma tana gwada bayanai a kansu kamar yadda babi na 8 ya gwada rubutu.

## 1. Siffar jeri

`@N` lamba ce, `@S` rubutu ne. Layin oda adadin rabo ne, sannan abinci.

```ring
? Lx("[@N, @S]").Match([ 42, "hello" ])
#--> TRUE
? Lx("[@N, @S]").Match([ "hello", 42 ])
#--> FALSE
```

## 2. Nawa na kowanne

`@N1-3` yana nufin lambobi ɗaya zuwa uku.

```ring
? Lx("[@N1-3, @S]").Match([ 1, 2, "end" ])
#--> TRUE
? Lx("[@N1-3, @S]").Match([ 4, 5, 6, 7, "extra" ])
#--> FALSE
```

## 3. Siffa a cikin siffa

```ring
? Lx("[@N, [@N2], @N]").Match([ 1, [ 2, 3 ], 4 ])
#--> TRUE
```

## 4. Siffar lamba

Siffar lamba tana sa wa hali suna. `Prime` ɗaya ce; 17 tana da shi, 18 ba ta da shi.

```ring
oNx = new stzNumbrex("{@Property(Prime)}")
? oNx.Match(17)
#--> TRUE
? oNx.Match(18)
#--> FALSE
```

## 5. Ninki, da adadin lambobi

```ring
oNx5 = new stzNumbrex("{@Relation(Mod:5=0)}")
? oNx5.Match(10)
#--> TRUE
? oNx5.Match(13)
#--> FALSE
oNx4 = new stzNumbrex("{@Digit4}")
? oNx4.Match(1234)
#--> TRUE
? oNx4.Match(123)
#--> FALSE
```

{{exercise:ex-09-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka gwada jeri a kan siffar iri da adadi, ka saka siffa a cikin wata, ka gwada
  lambobi don hali, ninki da adadin lambobi.
- **Me ya sa yake da muhimmanci:** bayanai marasa kyau bayanai ne masu siffar da ba daidai ba. Siffar da aka
  rubuta sau ɗaya tana ƙin kowane layi mara kyau da zai taɓa zuwa, ta faɗi dalili.
- **Abin da ke tafe:** idan bayanai suna da layuka da shafuka, tebur ne, kuma tebur yana da tambayoyinsa.
