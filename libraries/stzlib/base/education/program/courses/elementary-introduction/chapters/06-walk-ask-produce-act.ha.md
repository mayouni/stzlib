# Tafiya, tambaya, samarwa, aiki

*Gabatarwa ta Farko · Babi na 6 · Fasaha FO-02: "Wanne daga cikin motsi huɗu ne wannan matakin?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Kowane shiri motsi huɗu ne ya ƙunsa. Yana **tafiya** ta cikin wurare, yana **tambaya** tambayoyi, yana
**samar** da sababbin daraja, kuma yana **aiki** a kan bayanai. Softanza tana sa wa kowane motsi suna, don
haka aiki yana rarrabuwa zuwa motsi, ba madauki ba.

## 1. Tafiya: wurare, sannan abin da ke can

Kicin yana duba kowace oda ta uku. Da farko wuraren, sannan ododin da ke waɗannan wuraren.

```ring
aOrders = [ "tea", "rice", "tea", "fish", "rice", "tea", "soup", "tea", "rice" ]
? @@( StzListQ([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]).FindW("@item % 3 = 1") )
#--> [ 1, 4, 7 ]
? @@( StzListQ(aOrders).ItemsAtPositions([ 1, 4, 7 ]) )
#--> [ "tea", "fish", "soup" ]
```

## 2. Tambaya: tambaya tana amsa TRUE ko FALSE

```ring
? StzListQ(aOrders).Contains("soup")
#--> TRUE
? Q("cold").IsLowercase()
#--> TRUE
```

## 3. Samarwa: mai samarwa yana yin sababbin daraja daga tsofaffi

Kuɗin shigar rana, an rubuta mayar da kuɗi a matsayin lamba mara kyau. Mai samarwa yana tacewa, yana
canzawa, yana rage ba tare da an rubuta madauki ɗaya ba.

```ring
oY = new stzYielder([ 12, 0, 30, -5, 18 ])
? @@( oY.Filter(:IsPositive) )
#--> [ 12, 30, 18 ]
? @@( oY.Map(:Double) )
#--> [ 24, 0, 60, -10, 36 ]
? oY.Reduce(:Sum)
#--> 55
```

## 4. Motsin suna haɗuwa

Tace, sannan ka rage: jimillar tallace-tallace na gaske.

```ring
? oY.FilterQ(:IsPositive).Reduce(:Sum)
#--> 60
```

## 5. Aiki: aikatau yana canza bayanai

```ring
oL = new stzList(aOrders)
oL.RemoveAll("tea")
? @@( oL.Content() )
#--> [ "rice", "fish", "rice", "soup", "rice" ]
```

## 6. Ana iya miƙa sharaɗi a matsayin bayanai

`ItemsW` yana ɗaukar tambayar da kanta a matsayin hujjarsa. Babi na gaba game da wannan ne.

```ring
? @@( StzListQ([ 12, 0, 30, -5, 18 ]).ItemsW("@item > 0") )
#--> [ 12, 30, 18 ]
```

Softanza kuma tana da abu mai tafiya na musamman, `stzWalker`, mai matakai, hanyoyi da tarihi. Yana zaune
a matakin `max` na ɗakin karatu, wanda wannan darasin ba ya ɗauka, saboda haka ba a nuna shi a nan ba.

{{exercise:ex-06-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka rarraba aiki zuwa tafiya (wurare), tambaya (tambayoyi), samarwa (mai samarwa) da
  aiki (aikatau), ka haɗa su ba tare da madauki ba.
- **Me ya sa yake da muhimmanci:** madauki yana ɓoye motsin da yake yi. Sa wa motsin suna yana sa shiri ya
  zama mai karantuwa ga wanda bai rubuta shi ba.
- **Abin da ke tafe:** bayyana abin da kake so ka bar injin ya yanke yadda.
