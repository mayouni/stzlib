### Wasa 10 · Ninka matrices da tayal-tayal

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

`a` matrix ce 32 x 64 kuma `b` 64 x 48, layi bayan layi. Rubuta `c = a x b`, 32 x 48:
`c[row][col]` jimla ce akan j na `a[row][j] * b[j][col]`. Scalars suna faɗin siffar: `k` = 64
tsawon ciki, `w` = 48 faɗin `b` da `c`.

`width w` yana mai da fitarwa matrix da ake aiki da ita a **tayal 16 x 16**: kowane rukuni na
zaruruwa 256 yana lissafa tayal ɗaya ta `c`, kuma zare yana kiran gidansa da `@row` da `@col`,
wurinsa cikin tayal da `@lx` (shafi, 0-15) da `@ly` (layi, 0-15).

Hanya mai sauƙi daidai ce kuma a hankali: kowane zare yana karanta lambobi 64 na `a` da 64 na `b`
daga ma'ajiya. Hanyar tayal tana juyawa `tiles t { k / 16 }` sau; a kowane juyi rukunin yana ajiye
tayal 16 x 16 ta `a` da ɗaya ta `b` a ma'ajiyarsa, kuma kowane zare yana ƙara sakamakon ninkawa
goma sha shida daga can. Kowace lamba ana karanta ta sau ɗaya ga kowane rukuni maimakon sau ɗaya
ga kowane zare. Farkon yana ajiye tayal ta `a`:

    stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }

Rubuta tayal ta `b` (layi `t * 16 + @ly`, shafi `@col`), sannan

    accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }
    body { @c = @acc }

`@acc` jimlar zaren ce mai gudana, ana kiyaye ta daga juyi zuwa juyi. Juya sau ɗaya kawai kuma
kowane gida yana da ninkawa goma sha shida na farko kawai: *mismatch at element 1*. Siffar ɓoye
wata matrix ce, 16 x 80 sau 80 x 32, don haka kwayar da ta haddace 64 da 48 tana faɗi a can.

**Abin da GPU ya yi ba kamar madauki ba:** madauki yana lissafa gida bayan gida. A nan an lissafa
gidaje 256 tare, kuma lambobin da duk suke buƙata an ɗauko su sau ɗaya, tare.
