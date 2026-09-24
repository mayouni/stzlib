# Koyar da duniya

*Gabatarwa ta Farko · Babi na 12 · Fasahohi KN-01 "Me wurin aikina ya sani, kuma ta yaya zan rubuta shi?" da KN-02 "Me ya biyo bayan abin da na rubuta?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Softanza ba ta san komai game da gidan abincinka, bankinka ko makarantarka ba har sai ka faɗa mata.
**Duniya** ita ce abin da ka faɗa mata: gaskiya, an rubuta kowace da kalmomi uku, da dokoki kaɗan game da
alaƙoƙin da ke tsakaninsu. Da zarar duniya ta wanzu, Softanza tana iya amsa tambayoyi a kanta, ta tabbatar
da amsoshin.

## 1. Faɗi gaskiya

Gaskiya ita ce *batun, alaƙa, abu*. `Know` yana faɗin abin da wani abu yake; `KnowRelation` yana faɗin
kowace alaƙa.

```ring
oKB = new stzKnowledgeGraph("menu")
oKB.Know("margherita", "dish").Know("tiramisu", "dish").Know("pizza", "dish")
oKB.KnowRelation("margherita", "kind-of", "pizza")
oKB.KnowRelation("pizza", "kind-of", "food")
oKB.KnowRelation("margherita", "contains", "tomato")
? @@( oKB.Query([ "?x", "is-a", "dish" ]) )
#--> [ "margherita", "tiramisu", "pizza" ]
? @@( oKB.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato" ]
```

## 2. Tambaya tana amsawa daga abin da aka rubuta

Babu wanda ya rubuta cewa margherita iri ce ta abinci. Tambaya tana faɗin abin da aka rubuta kawai.

```ring
? @@( oKB.Query([ "margherita", "kind-of", "?o" ]) )
#--> [ "pizza" ]
```

## 3. Doka tana sa tunani ya yiwu

`kind-of` yana sarƙa: margherita iri ce ta pizza, pizza iri ce ta abinci. Bayyana alaƙar mai wucewa, kuma
`Prove` yana bin sarƙar ya nuna kowane mataki.

```ring
oKB.ConstrainRelation("kind-of", :Transitive)
aProof = oKB.Prove([ "margherita", "kind-of", "food" ])
? aProof[:verdict]
#--> TRUE
? aProof[:narration]
#--> proved: margherita kind-of pizza kind-of food
```

## 4. Duniya fayil ne da za ka iya karantawa

```ring
? oKB.ExportToKnow()
#--> knowledge "menu"
#--> margherita | is-a | dish
#--> margherita | contains | tomato
#--> kind-of | transitive
```

## 5. Duniyar da wannan darasin yake gudana a kai

Babukan wannan darasin suna tunani a kan fayil na duniya. Ga shi, an tambaye shi. Abin da yake bugawa ya
dogara da duniyar, saboda haka gudanar da shi.

```ring
? EduWorldName()
? @@( EduWorld().Query([ "?o", "requested", "?d" ]) )
```

{{exercise:ex-12-01}}

{{exercise:ex-12-02}}

## Taƙaitawa

- **Abin da ka cimma:** ka faɗi gaskiya da kalmomi uku kowace, ka tambaye su, ka bayyana alaƙa ɗaya mai
  wucewa, ka sa Softanza ta tabbatar da sarƙa ta ba da labarin kowane mataki; sannan ka ga duniyar a matsayin
  fayil mai sauƙi da take.
- **Me ya sa yake da muhimmanci:** Softanza ba ta san gaskiyar duniya ba. Ta san duniyar *ka*, kuma abin da
  ka koya mata kawai, shi ya sa ana iya bin amsoshinta zuwa layin da ka rubuta.
- **Abin da ke tafe:** idan duniyar tana da giɓi, Softanza tana tambayarka game da shi.
