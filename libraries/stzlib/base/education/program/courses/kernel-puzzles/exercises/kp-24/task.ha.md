### Wasa 24 · Matrix mai ƙaranci sau vector

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Matrix mai ƙarancin lambobi marasa sifili ba a adana ta gaba ɗaya. A nan an adana ta **shigarwa takwas a kowane layi**: vector `a`
yana ɗauke da ƙimar shigarwar, vector `b` yana ɗauke da **ginshiƙin** da kowacce take ciki, kuma layi `i` yana da shigarwa daga 8*i
zuwa 8*i + 7 (ana cika layin da bai kai takwas ba; wannan shi ne tsarin faɗi-ɗaya). `x` vector ne mai yawa mai lamba ɗaya ga kowane
ginshiƙi. Sa a cikin `y`, ga kowane layi, haɗinsa da `x`: jimillar ƙima sau `x` na ginshiƙinta a kan shigarwar layin.

    in a
    in b
    in x
    out y

Sabon abu shi ne **gather** (tattarawa): `@x[@b[k]]` yana karanta `x` ba a wurin zaren kansa ba sai a wurin da wani vector ya
ambata. A GPU tattarawa ita ce kuɗin aikin ƙaranci: karatun `x` yana sauka inda ginshiƙai suka ce, don haka zaren maƙwabta suna
karanta wurare masu nisa, kuma yawancin faɗin hanya da wasannin masu yawa suka yi amfani da shi yana ɓacewa. Akwai amsa ta biyu mai
kyau da ke juyawa a kan lambobin shigarwar kansu; ka same ta. Mai dubawa yana karɓar duka biyun kuma yana ambaton abin da kusan-daidai
ya yi kuskure a ciki: wanda ke musanya ƙima da ginshiƙai, wanda matakin layinsa 7 ne, wanda ke karanta shigarwa tara don haka yake
aron ta farko ta layin da ke biye, da wanda ya manta tattarawa yana ninkawa da wurin da ke cikin layi.

**Abin da GPU ya yi dabam da madauki:** madauki a kan layuka madauki ne a kan shigarwa a cikin madauki a kan layuka. A nan kowane
layi zare ne na kansa kuma yana tafiya ne kawai a kan shigarwarsa takwas. Wannan shi ne siffar haɗin ƙaranci `Spmv` na ɗakin
karatu, da bambanci ɗaya: yana karɓar layuka masu tsawo kowane (tsarin CSR, inda layi yake farawa inda tazara ta ce) kuma yana zaɓa
tsakanin zare ɗaya ga layi, ga gajeru, da rukuni ɗaya ga layi, ga dogaye.
