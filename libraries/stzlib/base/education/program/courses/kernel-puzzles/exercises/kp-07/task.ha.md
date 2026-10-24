### Wasa 7 · Hannaye masu yawa, zagaye na farko

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Jeri `a` na lambobi 16,384 (0, 0.1, 0.2 ... 0.9, 0, 0.1 ...). Kana son jimlarsu. Zare ɗaya ba zai iya
ƙara lambobi 16,384 da sauri ba, amma zaruruwa 1,024 kowanne na iya ƙara 16: rubuta kwayar da zaren
`i` ke jimla tagarsa, `c[i] = a[16i] + a[16i+1] + ... + a[16i+15]`, cikin jeri na jimloli 1,024 na ɓangare.

Jimla mai iyaka ana rubuta `sum(k, from, to, expression)`: `k` yana tafiya daga `from` har zuwa amma
ba ya haɗa da `to`, kuma kalmar na iya amfani da `k`. Shigarwa ta fi fitarwa tsawo a nan; bayyana su
kamar koyaushe:

    in a
    out c

Jimla 15 maimakon 16 kuma kowane ɓangare ba daidai ba ne tun na farko; zame tagar da 1 maimakon 16
kuma ɓangare na farko kaɗai ke daidai -- mai dubawa yana faɗin abin ko ta yaya.

**Abin da GPU ya yi ba kamar madauki ba:** madauki yana ƙara lambobi 16,384 ɗaya bayan ɗaya, matakai
dubu goma sha shida. A nan zaruruwa 1,024 kowanne ya ɗauki matakai goma sha shida, gefe da gefe: aikin
ɗaya ne, jira ɗaya bisa dubu.
