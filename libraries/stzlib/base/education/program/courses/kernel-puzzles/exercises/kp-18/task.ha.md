### Wasa 18 · Zagaye zuwa ikon biyu

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Kowane abu na `a` girma ne, daga 0 zuwa 3,999. Sa a cikin `c` mafi ƙanƙantar ikon biyu da ke ɗaukarsa,
kuma ba ƙasa da 1 ba: 1 ga 0 da 1, 2 ga 2, 4 ga 3 da 4, 8 daga 5 zuwa 8, haka dai har 4,096.

Yawan ninkawa yana dogara ga girman, don haka kernel yana buƙatar madauki da tsawonsa ke bambanta daga
abu zuwa abu. Wannan shi ne `iterate`:

    in a
    out c
    body { @c = iterate(k, 0, 40, s, 0.5, s * 2, s >= @a) }

`iterate(k, from, to, s, init, step, stop)` yana gudanar da **yanayi** `s`, da ke farawa daga `init`; a
kowane zagaye `k` yana ƙirgawa daga `from` kuma yanayin ya zama `step`. Idan sharaɗin `stop` na zaɓi ya
cika bayan zagaye, madauki yana ƙarewa da yanayin wannan zagaye, kuma ƙimarsa ita ce yanayin. A nan:
fara daga rabi, ninka, ka tsaya da zarar yanayin ya ɗauki girman. Madauki yana gudana zagaye 4,096 a
mafi yawa komai ka rubuta, don haka kernel koyaushe yana ƙarewa, kuma ana ƙin tsayin zahiri da ya wuce
haka. `sum(k, a, b, e)` ita ce shari'ar musamman da ke ƙara `e` a kowane zagaye.

Yanayi na iya zama float, int (rubuta `int(1)` don fara ɗaya) ko vector. Akwai amsa ta biyu madaidaiciya
ba tare da `stop` ba, da ta uku da yanayin int: nemo su. Mai dubawa yana karɓar dukkan uku, kuma yana
faɗin abin da kusan-amsa ke kuskure a ciki: tsayawa da `>` maimakon `>=`, farawa daga 1, zagaye kaɗan.

**Abin da GPU ya yi ba kamar madauki ba:** babu komai a cikin amsa. A cikin kuɗi kuwa, da yawa. Kowane
zare yana gudanar da kwafinsa na wannan madauki, zagaye goma sha uku ga girman 3,000 da ɗaya ga girman
1. Zaruruwan rukuni suna tafiya tare, don haka rukunin da ke da zare mai buƙatar zagaye goma sha uku yana
jira goma sha uku, kuma zaruruwan da suka gama suna jiransa. Tsayawa da wuri tana adana aikin zare, ba
lokacin rukuninsa ba, sai idan girman da ke maƙwabtaka sun yi kama.
