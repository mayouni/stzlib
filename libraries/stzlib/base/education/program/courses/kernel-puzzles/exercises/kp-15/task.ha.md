### Wasa 15 · Haske a kan fili

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Kowane abu wani wuri ne a kan fili, kuma shigarwa uku suna ɗauke da hanyar da filin ke fuskanta a
wurin, wato normal ɗinsa: `nx`, `ny` da `nz`. Wani haske yana haskakawa a kan `(sx, sy, sz)`, wato
`(2, -1, -2)`. Fili yana da haske gwargwadon cosine na kusurwar da ke tsakanin hanyoyin biyu, kuma
filin da ya juya baya ga hasken ba ya samun komai. Rubuta kernel da ke sa hasken kowane wuri, daga 0
zuwa 1, a cikin `c`.

Lambobi uku da suka haɗu ƙima ɗaya ne, vector:

    vec3(@nx, @ny, @nz)

`dot(a, b)` yana ninka vectors biyu sashe da sashe sannan ya tara; ga hanyoyi biyu masu tsawon ɗaya,
shi ne cosine. `normalize(v)` yana mai da vector tsawon ɗaya, `length(v)` yana faɗin tsawonsa, kuma
`.x`, `.y`, `.z` suna karanta sashe ɗaya (`.zyx` yana karanta uku, a juye). Lissafi yana tafiya
sashe da sashe, kuma lambar da ta haɗu da vector ana shimfiɗa ta a kansa: `vec3(sx, sy, sz) / 3`.

Fitarwa tana ɗauke da lamba ɗaya ga kowane abu, don haka dole a rage vector kafin ƙarshe: ana ƙin
`@c = normalize(...)`. Haka kuma ba a kwatanta vector gaba ɗaya: kwatanta sashe, ko dot.

**Abin da GPU ya yi ba kamar madauki ba:** lissafi iri ɗaya, an rubuta shi daban. GPU ya daɗe yana
aiki da vectors, wurare da launuka, kuma harshensa yana da `vec3` da `dot` a ciki; kernel yana faɗin
haka da kalmomi huɗu inda madauki zai rubuta ninkawa tara. Inda amsar ke buƙatar tushen murabba'i,
na'urar tana zagaye lambarta ta ƙarshe yadda take so, don haka wannan wasa yana yarda da bambanci na
0.00001.
