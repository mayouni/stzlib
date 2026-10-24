### Wasa 5 · Zaruruwan da ba su da abu

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Ninka jeri na lambobi 4,000 sau biyu kuma -- amma wannan karon KAI ne za ka rubuta mai tsaro na iyaka.

Zaruruwa suna zuwa a rukunoni na 256. Ga abubuwa 4,000 na'urar tana fara rukunoni 16: zaruruwa
4,096, kuma na ƙarshe 96 ba su da abu. Zaren da ya wuce ƙarshe ba zai rubuta ba. Mai tsaro layi ne
na kansa, sharaɗi a kan `@i` (lambar zaren) da `n` (adadin abubuwa):

    in a
    out c
    guard { @i < n }

Gwada wasan ta hanyoyi uku. Da mai tsaro: *verified*. Da `guard none`: zaruruwa 96 ƙari suna rubuta
bayan yankin, cikin gefen mai dubawa, kuma hukunci yana faɗin na farko: *write-outside at element
4001*. Da `guard { @i < n - 1 }`: abu 4000 ba a rubuta ba, kuma hukunci *mismatch at element 4000*.
Mai dubawa yana raba kurakurai biyun.

**Abin da GPU ya yi ba kamar madauki ba:** madauki yana tsayawa idan ya kai ƙarshe. GPU ba ya tsayawa;
yana fara rukuni gaba ɗaya a lokaci ɗaya, kuma zaruruwan da suka wuce ƙarshe suna nan ko kana so ko
ba ka so. Mai tsaro ne hanyar faɗa musu su yi shiru.
