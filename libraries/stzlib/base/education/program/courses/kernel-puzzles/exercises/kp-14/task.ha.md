### Wasa 14 · Jefa ɗan lido

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Kowane abu na `a` iri ne: 0, 7, 1, 8, 2, 9 ... (lambobi cikakku har zuwa 12). Wani sanannen janareta
yana mai da iri lambar gaba ta `iri x 1664525 + 1013904223`, kuma ɗan lido mai fuska dubu yana riƙe
lambobi uku na ƙarshe. Rubuta kernel da ke sa jefawar kowane iri a cikin `c`: iri 7 yana ba da 898.

Lambobin nan cikakku ne, kuma kernel yana faɗin haka:

    in a int
    out c int

`int` yana mai da `@a` lamba cikakkiya, kuma kowane aiki a kanta cikakke: `/` yana jefar da saura,
`%` kuma yana ba da shi. Lamba cikakkiya da ta haɗu da int ta zama int; mai digo kuwa float ce.

Gwada da float da farko, da `in a` da `out c`, kuma mai dubawa yana faɗin abu na 1. Float yana riƙe
lambobin binary 24, kusan na goma bakwai, kuma 1,013,904,223 yana da goma: a matsayin float ya zama
1,013,904,192, don haka iri 0 yana ba da 192, ba 223 ba. Int kuwa yana riƙe kowace lamba.

Int da float ba sa haɗuwa ba tare da an faɗa ba: ana ƙin `@a * 0.5`. Rubuta `float(@a) * 0.5`, ko
`int(...)` a ɗaya hanyar.

**Abin da GPU ya yi ba kamar madauki ba:** babu komai, wannan karon: madauki na float a CPU yana rasa
lambobin iri ɗaya. Abin da ya dace a sani shi ne yadda int na GPU ke yi a gefensa. Yana komawa farko
bayan 2,147,483,647, kamar a kowane CPU. Kuma a kan RTX 3050 da aka gina wannan darasi, mai fassara
na GPU yana ɗaukar `%` na int mara kyau kamar ba shi da alama (-7 % 4 ya ba da 1, inda WGSL ke cewa
-3), don haka mai fassara yana rubuta kowace saura ta int da kansa, kuma da kwatantawa ne mai dubawa
ya gano haka.
