### Wasa 23 · Jimilla mai gudana da ke sake farawa

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Vectors biyu na lambobi 4,096: ƙima `a` (0 zuwa 12) da alamomi `b`. Alama **ƙasa da 2** tana fara **yanki** a wannan abu.
Sa a cikin `c`, ga kowane abu, jimillar ƙimar yankinsa har zuwa kansa, a cikin kowane rukuni na 256 (rukuni yana sake farawa
a gefensa).

Jimillar wasan da ya gabata tana ratsa dukan rukuni. Wannan dole ta sake farawa a kowane farawa, kuma babu zare da ke ganin
inda yankunan wasu suke farawa, don haka kowane abu yana lissafa **lambar yanki**: yawan farawa har zuwa kansa har da shi.
Wannan jimilla ce mai gudana ta 1 da 0, scan na wasannin ƙarshe. Sa'an nan abu yana jimillar abubuwan da ke gabansa ko shi kansa
masu raba lambar yankinsa:

    in a
    in b
    out c
    shared t 256
    shared s 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @s[@l] = when(@b < 2, 1, 0) }
    stage { @r[@l] = sum(j, 0, 256, when(j <= @l, @s[j], 0)) }

Rubuta jikin. Akwai amsa ta biyu mai kyau da ke ƙidaya farawa kafin abu kaɗai tana ƙara nasa farawa lokacin kwatanta lambobi;
ka same ta. Mai dubawa yana karɓar duka biyun kuma yana ambaton abin da kusan-daidai ya yi kuskure a ciki: wanda ya manta
sake farawa (jimillar mai gudana ta yau da kullum), wanda ke kwatanta alamomin kansu ba lambobin yanki ba, da wanda ke ƙidaya
farawa kafin abu kaɗai, har farawa ya shiga yankin da ya gabace shi.

**Abin da GPU ya yi dabam da madauki:** madauki yana riƙe jimilla ɗaya mai gudana ya mayar da ita sifili idan ya haɗu da farawa,
don haka dole ya karanta abubuwa bisa tsari. A nan kowane abu ya koyi yankinsa daga ƙidaya ya kuma jimillar abubuwan yankinsa
na baya ba tare da jiran wani zare ba. `SegmentedScan` na ɗakin karatu yana saka sake farawa a cikin scan ɗin kansa: ana haɗa
nau'i-nau'i (farawa, jimilla) har farawa yana watsar da abin da ya riga shi, sai scan iri ɗaya mai matakai uku ya yi aiki a kan
dukan vector. `SegmentedReduce` yana riƙe jimillar ƙarshe ta kowane yanki: lamba ɗaya ga kowane yanki.
