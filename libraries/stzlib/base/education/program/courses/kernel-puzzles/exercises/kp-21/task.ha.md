### Wasa 21 · Tattara manya

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Vector `a` mai lambobi 4,000, kowacce daga 0 zuwa 12. A kowane rukuni na 256, riƙe lambobin da suka fi **5** ka
tattara su, bisa tsarinsu, a gaban wuraren rukunin; sauran wuraren rukunin 0 ne. Rukuni da ya ɗauki 1, 9, 2, 7, 11,
3 ... yana amsawa 9, 7, 11 ... sannan sifili. Wannan shi ne **matse rafi** (stream compaction).

Madauki zai ƙara kowace lambar da aka riƙe a ƙarshen jerin fitarwa. Babu zare da ya san tsawon fitarwar zuwa yanzu,
don haka amsa tana zuwa daga lamba da kowane zare zai iya lissafawa shi kaɗai: **matsayi** na abin da aka riƙe,
wato nawa ne aka riƙe kafin shi. Wannan jimilla ce mai gudana ta 1 da 0, scan na wasan da ya gabata. A nan yana da
jinkiri kuma mai sauƙi, aka sa shi a jeri na biyu ta stage nasa:

    in a
    out c
    shared t 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @r[@l] = sum(j, 0, 256, when(j <= @l, when(@t[j] > 5, 1, 0), 0)) }

`@r[j]` yanzu yana cewa nawa ne aka riƙe har zuwa wuri `j` har da shi. Wuri `@l` na fitarwa yana ɗauke da abin da aka
riƙe wanda matsayinsa `@l + 1`: rubuta jikin da zai same shi. Kernel yana rubuta wurin da yake da shi kaɗai, don haka
tattarawa tana faruwa ne da wuri yana neman abinsa, akasin madauki da ke turawa. Akwai amsa ta biyu mai kyau tare da
ƙidayar matsayi ta wata hanya (abubuwan da aka riƙe kafin kowane wuri kaɗai); ka same ta ma. Mai dubawa yana karɓar
duka biyun kuma yana ambaton abin da kusan-daidai ya yi kuskure a ciki: wanda ke mai da ƙanana sifili ba tare da
tattara komai ba, wanda ke karanta matsayi sama da ɗaya, da wanda ke riƙe 5.

**Abin da GPU ya yi dabam da madauki:** fitarwar madauki tana girma yayin da yake tafiya, don haka kowane ƙari yana
dogara ga wanda ya riga shi. A nan kowane zare ya koyi wurinsa daga ƙidaya da aka yi lokaci guda, kuma babu wanda ya
jira wani. `Compact` ta ɗakin karatu tana yin shi yadda GPU ke so idan dukan vector ɗin shi ne matsalar: kowane abin da
aka riƙe yana sa kansa a matsayinsa, wanda scan a kan dukan vector ɗin ya samo, kuma yawan abubuwan da aka riƙe yana
dawowa a matsayin lamba ɗaya.
