# Zana amsar

*Gabatarwa ta Farko · Babi na 11 · Fasahohi SE-01 "Shin hoto zai amsa wannan da sauri fiye da lamba?" da SE-02 "Ina, kuma nawa?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

`[ 3, 9, 15 ]` amsa ce daidai ga "ina ring yake?". Ba amsa ce mai sauri ba. Hoto yana sanya amsar inda ido
yake tuni. Softanza tana zana amsoshi da rubutu, saboda haka zane abu ne da shiri zai iya bugawa, shafi zai
iya riƙewa, kuma mai tsaro zai iya dubawa, layi bayan layi.

## 1. Nuna ina, ba wuri kawai ba

```ring
o1 = new stzString("fjringljringdjringg")
? @@( o1.FindAll("ring") )
#--> [ 3, 9, 15 ]
? o1.vizFind("ring")
#--> fjringljringdjringg
#--> --^-----^-----^----
```

## 2. Da lambobin a ƙarƙashin alamomin

```ring
? o1.vizFindXT("ring", [ :Numbered = TRUE ])
#--> fjringljringdjringg
#--> --^-----^-----^----
#--> 3     9     15
```

## 3. Zane hoton alaƙa ne

Oda tana kaiwa kicin, kuma kicin yana kaiwa tebur. Zanen yana amsa tambayoyi, sannan ya zana kansa.

```ring
oG = new stzGraph("kitchen")
oG {
	AddNodeXT("order", "Order")
	AddNodeXT("kitchen", "Kitchen")
	AddNodeXT("table", "Table")
	Connect("order", "kitchen")
	Connect("kitchen", "table")
}
? oG.PathExists("order", "table")
#--> TRUE
? @@( oG.Neighbors("kitchen") )
#--> [ "table" ]
oG.Show()
#--> │ Order │
#--> │ Table │
```

## 4. Nawa: sanda ɗaya ga kowane abinci

```ring
oP = new stzHBarPlot([ :tea = 6, :rice = 3, :fish = 2 ])
oP.Show()
#--> Tea │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
#--> Fish │ ▇▇▇▇▇▇
```

## 5. Sanduna ɗin nan, a tsaye

```ring
oP2 = new stzVBarPlot([ :tea = 6, :rice = 3, :fish = 2 ])
oP2.SetHeight(4)
oP2.Show()
#--> Tea Rice Fish
```

Taswirori suna da wuri a nan su ma: Softanza tana zana bayanai a taswirar wuri na gaske, ta zaɓi tsarin da
ba ya yin ƙarya game da su. Wannan matakin ƙwararre ne na wannan fasahar, kuma darasi na gaba.

{{exercise:ex-11-01}}

{{exercise:ex-11-02}}

## Taƙaitawa

- **Abin da ka cimma:** ka zana inda kalma take, ka zana zanen alaƙa uku ka yi masa tambaya, ka zana ododin
  abinci uku a matsayin sanduna, kwance sannan a tsaye.
- **Me ya sa yake da muhimmanci:** nunawa ita ce kayan aunawa. Lamba na iya zama daidai amma ba a karanta
  ta ba; hoto ana karanta shi nan take, kuma hoton da aka yi da rubutu har yanzu mai tsaro zai iya dubawa.
- **Abin da ke tafe:** koya wa Softanza abin da wurin aikinka ya sani, domin ta iya tunani a kai.
