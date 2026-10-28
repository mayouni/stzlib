### Wasa 17 · Ƙirga ƙuri'u

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Mutane 4,000 sun jefa ƙuri'a, kowanne ga ɗaya daga cikin 'yan takara 13 masu lamba 0 zuwa 12: ƙuri'ar
mutum `i` ita ce `a[i]`. Ƙirga ƙuri'un kowane ɗan takara a cikin `h`, ta yadda `h[k]` zai zama yawan
mutanen da suka zaɓi `k`.

Har yanzu kowane zare yana rubuta abinsa. A nan zaruruwa 4,000 suna rubutu a cikin masu ƙirga 13, kuma
da yawa daga cikinsu a cikin ɗaya a lokaci ɗaya. Rubutu na yau da kullum zai rasa ƙuri'u: zaruruwa biyu
suna karanta 307, dukansu suna rubuta 308, kuma ƙuri'a ɗaya ta ɓace. Don haka ana bayyana fitarwar a
matsayin masu ƙirga da ke ƙarawa kawai:

    in a
    out h atomic 13
    body { @h[@a] += 1 }

`@h[index] += value` yana ƙara `value` ga mai ƙirga `index` lafiya, ko wane ne ke ƙarawa a lokaci
ɗaya; `max=` da `min=` suna riƙe mafi girma ko mafi ƙanƙanta. Masu ƙirga suna ɗauke da lambobi cikakku
kuma suna farawa daga 0. Index da ke wajen 0 zuwa 12 ana watsar da shi, ba a rubuta ba. Tsarin isowar
ƙuri'u ba zai canza jimla ba, don haka ƙirgar mai dubawa, a kan CPU, ita ce amsar da na'urar dole ta
bayar.

**Abin da GPU ya yi ba kamar madauki ba:** madauki yana ƙirga ƙuri'a ɗaya a lokaci guda, kuma ba ya
taɓa sanya hannu biyu a kan mai ƙirga ɗaya. A nan ana ƙirga kowace ƙuri'a a lokaci ɗaya, kuma na'urar
tana sa zaruruwan da ke raba mai ƙirga su bi layi. Yawan ƙuri'un ɗan takara, tsawon layinsa, shi ya sa
histogram mai sauri a kan GPU ke ba kowane rukuni masu ƙirgarsa da farko, a cikin memory na tarayya,
sannan ya tara su a ƙarshe.
