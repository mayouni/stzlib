### Wasa 8 · Hannaye masu yawa, naɗewa

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Jimloli 1,024 na ɓangare na wasa 7 yanzu jeri `c` ne, kuma `m` (sikela, 1,024) adadinsu ne. Rubuta
kwayar da zai naɗe su cikin lamba ƊAYA: `d[0] = c[0] + c[1] + ... + c[m-1]`. Fitarwa tana da abu ɗaya.

    in c
    scalar m
    out d

Naɗe `m - 1` daga cikinsu kuma jimlar ta rasa ɓangare na ƙarshe; kwafi `@c` kuma kana da ɓangare na
farko, ba jimla ba. Dukansu *mismatch at element 1* ne -- ɗaya ne kaɗai.

Tare, wasanni 7 da 8 raguwa ne ta zagaye biyu: zaruruwa dubu kowanne ya jimla goma sha shida, sannan
zare ɗaya ya jimla dubun. Haka GPU ke ƙara lambobi miliyan ɗaya: ba ɗaya bayan ɗaya har ƙarshe ba, ba
zare ɗaya ne yake yin duka ba.

**Abin da GPU ya yi ba kamar madauki ba:** jimlar madauki guda ɗaya an raba ta zuwa ƙananan jimloli
dubu waɗanda babu zaren da ya jira, sannan an tara su sau ɗaya.
