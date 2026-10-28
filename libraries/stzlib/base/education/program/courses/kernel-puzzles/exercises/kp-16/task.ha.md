### Wasa 16 · Juya wuraren

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Shigarwar `p` tana ɗauke da wurare 4,000, kowanne `vec2`, kuma kernel dole ya juya kowanne a kewayen
asalin da kusurwar da cosine ɗinta `c` (0.6) da sine ɗinta `s` (0.8), kusan digiri 53. Wuri
`(x, y)` da aka juya da wannan kusurwa ya zama `(c x - s y, s x + c y)`. Sa kowane wurin da aka juya
a cikin `q`.

A wannan karon shigarwa da fitarwa suna ɗauke da vectors, kuma bayanin yana faɗin haka:

    in p vec2
    scalar c
    scalar s
    out q vec2

Ma'ajin `vec2` yana ɗauke da lambobi biyu ga kowane abu, gefe da gefe: abu na 7 shi ne lambobi 14 da
15. `@p` shi ne wurin abin, `@p.x` da `@p.y` lambobinsa biyu, kuma ƙimar jiki dole ta zama `vec2`,
kamar `vec2(..., ...)`. Ana ƙin lamba a can, da `vec3` ma.

Akwai wasu hanyoyin rubuta wannan juyawa. Kowane sabon sashe dot ne da layi ɗaya na juyawar, kuma
wurin da aka juya shi ne kuma `c` sau wurin tare da `s` sau wurin da aka juya kwata, `vec2(-@p.y,
@p.x)`. Mai dubawa yana karɓar dukkan uku.

**Abin da GPU ya yi ba kamar madauki ba:** madauki zai bi jerin lambobi biyu-biyu yana riƙe haɗin a
kansa: wuri 2i shi ne x, 2i + 1 shi ne y. A nan bayanin ne ke riƙe shi. Kernel yana karanta wuri yana
rubuta wuri, kuma haɗin yana wuri ɗaya, don haka ba zai iya karkacewa ba.
