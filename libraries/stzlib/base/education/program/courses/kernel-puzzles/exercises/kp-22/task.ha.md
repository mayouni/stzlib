### Wasa 22 · Jera rukuni

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Vector `a` mai lambobi 4,096, kowacce daga 0 zuwa 12. Jera **kowane rukuni na 256** daga ƙarami zuwa babba: ƙaramar lambar
rukunin ta farko. (Rukuni na ƙarshe gajere zai ga lambobinsa da suka ɓace a matsayin 0.)

Madauki zai musanya maƙwabta har sai babu abin da ke motsi. Babu zare da ke ganin dukan tsari, don haka amsa tana zuwa daga
abin da kowane zare zai iya lissafawa shi kaɗai: **matsayinsa**, wato nawa ne a rukuni suke gaban lambarsa. Lambobi daidai
suna buƙatar rarrabewa, in ba haka ba biyu daga cikinsu su nemi matsayi ɗaya kuma wuri ya zama fanko: a nan, wanda ke zaune
da farko a rukuni shi ne ke gaba.

    in a
    out c
    shared t 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l] or (@t[j] == @t[@l] and j < @l), 1, 0)) }

`@r[l]` yanzu shi ne wurin da lambar da ke `l` take zuwa. Kamar wasan da ya gabata, kernel yana rubuta wurin da yake da shi
kaɗai, don haka wuri `@l` yana neman lambar da matsayinta `@l`: rubuta wannan jiki. Akwai amsa ta biyu mai kyau da ke rarrabe
daidai ɗin ta wata hanya (wanda ke zaune daga baya shi ne ke gaba); ka same ta. Mai dubawa yana karɓar duka biyun kuma yana
ambaton abin da kusan-daidai ya yi kuskure a ciki: daidai ɗin masu matsayi ɗaya, wanda ke barin ramuka da ninki; ƙidaya da ta
haɗa lambar kanta, wadda ke ɗaga kowane matsayi da ɗaya; da kuma matsayi ta mafi girma, wanda ke jera zuwa ƙasa.

**Abin da GPU ya yi dabam da madauki:** madaukin jerawa yana wuce lambobi ta kan juna, kwatanta ɗaya bayan ɗaya. A nan an
kwatanta lambobi 256 duka da 256 lokaci guda, kuma kowacce ta koyi wurinta daga ƙidayar: kwatance 65,536 a mataki ɗaya, babu
zare da ke jiran wani. Wannan almubazzaranci ne ga vector babba, shi ya sa `Sort` na ɗakin karatu ba ya yin haka: yana yin
zagaye takwas na ɗigo huɗu, kowanne yana sa kowane maɓalli a wurinsa ta ƙidayar maɓallan da lambarsu ke gaban tasa, don haka
aikin yana girma da girman vector ba da murabba'insa ba.
