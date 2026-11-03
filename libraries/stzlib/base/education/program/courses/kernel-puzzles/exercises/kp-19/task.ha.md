### Wasa 19 · Abin da ya canja tun bayan yanki na baya

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Ƙarar sarari (volume) tarin yanka ne, kuma kowane yanki akwatin layuka ne. Ƙarar `a` a nan yanka 4 ne na
ƙwayoyi 32 × 32 (siffar da aka ɓoye wata ce: yanka 3 na 16 × 32). Sa a cikin `c`, ga kowace ƙwaya, yawan
abin da ya canja tun yanki na baya: ƙwayar rage ƙwayar guda ɗaya yanki ɗaya a baya. Yanki na farko ba shi
da abin da ya riga shi, don haka yana riƙe darajarsa.

Kernel yana ganin ƙarar sarari ta layuka biyu da fitarwa ta yau da kullum ba ta da su:

    in a
    scalar w
    scalar d
    scalar p
    out c
    width w
    depth d
    body { @c = @a }

`width w` yana mai da fitarwar akwatin da faɗinsa ƙwayoyi `w`, ana aiki da shi da tayal 16 × 16; `depth d`
yana jera `d` daga cikin waɗannan akwatuna. Ƙwaya tana samun wurinta da sunaye uku: `@slice`, wato yankin da
take ciki, da `@row` da `@col`, wato layinta da ginshiƙinta **a cikin wannan yankin**. `@i` wurinta ne a
dukan ƙarar sarari, kuma lambar `p` ita ce yawan ƙwayoyin yanki ɗaya, don haka yanki ɗaya a baya shi ne
`@i - p`. Ana ƙin `@slice` ba tare da layin `depth` ba, kuma layin `depth` yana buƙatar layin `width`.
Karatu kafin abu na farko yana ba da 0, kamar ko'ina.

Akwai amsa ta biyu mai kyau da ke dogara ga wannan sifili, da ta uku da ke motsa reshen. Mai dubawa yana
karɓar duka uku, kuma yana ambaton abin da kusan-daidai ya yi kuskure a ciki: wanda ke kwatanta layuka maimakon
yanka, wanda ke rubuta girman yanki a matsayin lamba (yana aiki ne kawai ga siffar da aka nuna), da wanda
ke tsallake yanki na biyu.

Girman yanki yana zuwa a `p` ba a lissafa shi da `n / d` ba, da gangan: rabon lamba mai ɗigo ba daidai yake
a kowace na'ura ba (wasu suna ninka da juyayyen lamba, kuma a haɗe da ragewa ma'auni yana faɗuwa ƙasa da
abinsa kaɗan ya karanta wanda ya riga shi), don haka girman da ke shiga ma'auni ya fi kyau a ba da shi daidai.

**Abin da GPU ya yi dabam da madauki sau uku:** madaukai uku da suke cikin juna, a kan yanka, layuka da
ginshiƙai, sun tafi. Akwai zare ɗaya ga kowace ƙwaya, wanda yake sanin yankinsa, layinsa da ginshiƙinsa
daga wurinsa. Rukuninsa tayal 16 × 16 ne na yanki **ɗaya**, ba tayal da ke kan yanka biyu ba, shi ya sa
dole yanki ya zama cikakken adadin tayal. Kuɗin wannan wasa karatu biyu ne ga kowace ƙwaya, kowanne a jere:
zaren da ke maƙwabtaka a rukuni suna karanta adireshi maƙwabta, a yankin da kuma a yankin da ya gabace shi.
