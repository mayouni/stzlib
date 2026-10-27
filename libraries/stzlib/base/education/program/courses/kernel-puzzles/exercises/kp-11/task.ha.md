### Wasa 11 · Softmax, layi ɗaya ga kowane rukuni

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

`a` yana da layuka 16 na lambobi 256. Mai da kowane layi rabe-rabe da jimlarsu ta zama 1:
`c[i] = exp(a[i] - max) / sum`, inda `max` shi ne mafi girman ƙimar layin kuma `sum` jimlar
`exp(a - max)` akan layin. Rukuni ɗaya na zaruruwa 256 layi ɗaya ne.

Layin **reduce** yana naɗe jerin da aka raba zuwa gidansa na 0, yana raba shi biyu da shamaki a kowane
mataki: ƙima 256, sannan 128, 64 ... 1. `reduce m max` yana barin mafi girman ƙima a `@m[0]`;
`reduce s sum` yana barin jimlar a `@s[0]`.

    stage { @m[@l] = @a }
    reduce m max
    stage { @s[@l] = exp(@a - @m[0]) }
    reduce s sum
    body { @c = exp(@a - @m[0]) / @s[0] }

Bayan reduce gida na 0 kaɗai ke riƙe da amsar; sauran gidajen suna riƙe da abin da rabawa ta bari.
Raba da `@s[@l]` kuma abu na farko daidai ne (yana karanta gida na 0) amma na biyu ba haka ba:
*mismatch at element 2*. Ka manta da rabawa: *mismatch at element 1*.

Cire mafi girma ba ya canza amsar: gwada sigar da babu shi kuma ta tabbata a nan, akan lambobi
tsakanin 0 da 0.9. Yana nan don ranar da layin zai riƙe 1,000, wanda exp ɗinsa ba ya shiga float.

**Abin da GPU ya yi ba kamar madauki ba:** madauki yana neman mafi girma ta hanyar bin layin sau ɗaya
kuma yana tarawa ta hanyar bin shi kuma. A nan kowane bi matakai takwas ne na rabawa, faɗin zaruruwa 256.
