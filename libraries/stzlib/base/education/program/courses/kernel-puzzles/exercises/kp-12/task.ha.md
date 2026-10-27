### Wasa 12 · Yaya sauri zai iya kai?

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Rubuta `c = alpha * a + b` akan jeri biyu (`alpha` shi ne 2.5). Wasa na 2 ne da scalar, kuma za ka
same shi daidai a karon farko. Wasan shi ne abin da ke zuwa bayan hukuncin.

Da zarar kwayarka ta tabbata, shafin yana sake gudanar da ita akan abubuwa 4,194,304 kuma yana sa ta
ƙarƙashin **rufi** biyu na wannan na'ura, waɗanda aka auna a nan take da kwayoyin injin kansa:

- **rufin bandwidth**: bytes nawa a cikin daƙiƙa kwafi mai sauƙi ke motsawa a nan;
- **rufin lissafi**: ayyuka nawa a cikin daƙiƙa kwayar da ke ninkawa-da-tarawa kaɗai ke yi.

Kwayarka tana karanta lambobi biyu, tana rubuta ɗaya kuma tana yin ayyuka biyu: bytes 12 don ayyuka
2. Wannan aiki ne ƙasa da yawa ga kowane byte fiye da abin da na'urar za ta iya, don haka tana jiran
ma'ajiya, kuma lambar da ke da muhimmanci ita ce rabonta na rufin bandwidth. Shafin yana faɗin wane
rufi ne ya fi ƙasa gare ta.

Sannan gwada wannan, shi ma daidai ne:

    body { @c = alpha * @a + @b + 0 * sum(k, 0, 64, @a[k]) }

Yana ba da lambobi iri ɗaya, kuma kowane zare yana karanta ƙarin 64. Kwatanta rabon biyu. *verified*
yana cewa amsar daidai ce; ba ya cewa kwayar tana da kyau.

**Abin da GPU ya yi ba kamar madauki ba:** lokacin madauki matakansa ne. Lokacin kwaya shi ne mafi
jinkiri daga abubuwa biyu, bytes da take motsawa da lissafin da take yi, kuma a nan kusan koyaushe bytes ne.
