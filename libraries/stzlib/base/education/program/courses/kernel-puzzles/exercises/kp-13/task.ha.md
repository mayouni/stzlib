### Wasa 13 · Farashi biyu

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Jeri na yawa 4,000, `a`, yana ɗauke da 0, 7, 1, 8, 2, 9 ... (ba ya wuce 12), kuma lamba ɗaya `t` ita
ce 6. Raka'a `t` na farko na kowane yawa kuɗinsu 1 kowanne, kuma kowace raka'a bayan `t` kuɗinta 2.
Rubuta kernel da ke sa farashin kowane yawa a cikin `c`: 5 kuɗinsa 5, kuma 9 kuɗinsa 6 + 2 x 3 = 12.

Farashin yana da dabaru biyu, kuma wanda ya dace ya dogara ga yawan.
`when(sharaɗi, ƙima idan gaskiya ne, ƙima idan ba gaskiya ba)` shi ne wannan zaɓi:

    in a
    scalar t
    out c
    body { @c = when(@a <= t, ..., ...) }

Sharaɗin yana kwatanta ƙimomi, kamar yadda mai tsaro ke yi: `@a <= t`. Ba lamba ba ne, don haka
`(@a > t) * 2` ana ƙi shi, haka ma lamba a wurin sharaɗi, `when(@a - t, ...)`. Sa farashin biyu a
wurin juna, kuma mai dubawa yana faɗin abu na farko inda suka bambanta.

Akwai amsa ta biyu ba tare da `when` ba: farashin shi ne yawan, tare da abin da ya wuce `t` sau ɗaya
kuma. Nemo ta; mai dubawa ma yana karɓar ta.

**Abin da GPU ya yi ba kamar madauki ba:** a cikin madauki, `if` yana gudanar da gefe ɗaya ya tsallake
ɗayan. Zaruruwan rukuni suna tafiya tare, don haka wannan kernel yana lissafa farashin BIYU ya riƙe
ɗaya: WGSL ɗinsa shi ne `select(ƙima idan ba gaskiya ba, ƙima idan gaskiya ne, sharaɗi)`, ƙimar ƙarya
da farko. Zaɓi a kan GPU yana biyan gefe biyunsa. A nan kowane gefe layi ɗaya ne na lissafi, don haka
kuɗin kaɗan ne; idan gefe ɗaya ya yi tsawo, duk zaruruwan rukunin suna jiran sa.
