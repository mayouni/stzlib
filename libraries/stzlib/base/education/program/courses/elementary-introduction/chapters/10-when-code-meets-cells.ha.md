# Lokacin da lamba ta haɗu da ɗakuna

*Gabatarwa ta Farko · Babi na 10 · Fasaha PA-04: "Waɗanne ɗakuna ne suke amsa tambayata?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Menu na gidan abinci tebur ne: layi ɗaya ga kowane abinci, shafi ɗaya ga kowane bayani game da shi.
`stzTable` yana riƙe shi, yana zana shi, kuma yana amsa tambayoyi ta shafi, ta layi da ta ɗaki. Kuma shafi
jeri ne, saboda haka duk abin da ka tambayi jeri a babi na farko ana iya tambayar shafi.

## 1. Gina teburin, ka dube shi

Layin farko yana sa wa shafuka suna. Gudanar da ɗakin ka ga teburin an zana.

```ring
oT = new stzTable([
	[ :DISH, :PRICE, :ORDERS ],
	[ "tea",  200, 6 ],
	[ "rice", 500, 3 ],
	[ "fish", 900, 2 ]
])
oT.Show()
```

## 2. Siffarsa

```ring
? oT.NumberOfRows()
#--> 3
? oT.NumberOfCols()
#--> 3
? @@( oT.ColNames() )
#--> [ "dish", "price", "orders" ]
```

## 3. Shafi, layi

```ring
? @@( oT.Col(:PRICE) )
#--> [ 200, 500, 900 ]
? @@( oT.Row(2) )
#--> [ "rice", 500, 3 ]
```

## 4. Ɗaki, da inda daraja take

```ring
? oT.Cell(:PRICE, 3)
#--> 900
? @@( oT.FindInCol(:DISH, "fish") )
#--> [ 3 ]
```

## 5. Shafi jeri ne: yi masa tambayoyin jeri

```ring
? StzListQ(oT.Col(:ORDERS)).Sum()
#--> 11
? @@( StzListQ(oT.Col(:PRICE)).FindW("{ @item > 400 }") )
#--> [ 2, 3 ]
```

{{exercise:ex-10-01}}

## Taƙaitawa

- **Abin da ka cimma:** ka gina tebur daga layuka, ka karanta siffarsa, ka ɗauki shafi, layi da ɗaki, ka
  nemo daraja a cikin shafi, ka yi wa shafi tambayoyin babi na 7.
- **Me ya sa yake da muhimmanci:** yawancin bayanan duniya suna zuwa a matsayin teburi. Sanin cewa shafi
  jeri ne yana nufin ka riga ka san yadda za ka tambaye shi.
- **Abin da ke tafe:** wasu amsoshi sun fi kyau a zana su fiye da a buga su.
