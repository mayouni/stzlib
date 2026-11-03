### Wasa 20 · Jimillar da ke gudana a rukuni

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Vector `a` mai lambobi 4,000. Sa a cikin `c` **jimillar da ke gudana a cikin kowane rukuni na 256**: abu na
`i` a rukuni yana ɗauke da jimillar abubuwan rukunin daga 0 zuwa `i`. Kowane rukuni yana farawa daga
farko, don haka abu na 256 shi ne `a[256]` kaɗai, ba duk abin da ya riga shi ba. Rukuni na ƙarshe yana da
lambobi 160; zaren 96 da ke bayan ƙarshe ba sa ƙara komai.

Zaren 256 na rukuni suna ganin lambobin juna ta ƙwaƙwalwar rukunin (wasa na 9). Amsa mai jinkiri tana sa
kowane zare ya haɗa nasa gaba:

    in a
    out c
    shared t 256
    stage { @t[@l] = @a }
    body { @c = sum(j, 0, 256, when(j <= @l, @t[j], 0)) }

Wannan har ƙari 256 ne a zare ɗaya, kuma zaren suna jiran mafi tsawo. Akwai amsa mai sauri a matakai takwas,
kowanne yana ninka isa: a mataki `s` kowane zare yana ƙara lambar da ke nesa da `2^s` wurare a hagunsa. Yana
buƙatar jeri na biyu (stage ba ya karanta jerin da yake rubutawa), madauki `tiles` na zagaye takwas da stages biyu
a kowanne, da `pow(2, s)` don nisa. Karatu kafin farkon jeri yana ba da 0, don haka zaren gefe ba sa buƙatar
reshe. Ka same ta. Mai dubawa yana karɓar duka biyun kuma yana ambaton abin da kusan-daidai ya yi kuskure a
ciki: wanda ya bar lambar zaren kansa, wanda ba ya fara daga farko a kowane rukuni, da wanda ke da matakai
bakwai, wanda ya kai wurare 128 kawai a baya.

**Abin da GPU ya yi dabam da madauki:** madauki yana ɗaukar jimilla ɗaya daga abu zuwa na gaba, don haka na
uku yana jiran na biyu. A nan babu zare da ke jiran jimillar wani. A matakai takwas dukan jimilla 256 sun
ƙare, inda madauki ya ɗauki zagaye 256 ɗaya bayan ɗaya, a kan farashin kusan ninki takwas na ƙari. Wannan shi ne
matakin toshe na `Scan` na ɗakin karatu: yana yin jimillar kowane toshe na 256 haka, sannan na jimillolin
tosheshe iri ɗaya, sannan ya dawo da kowane toshe tazararsa.
