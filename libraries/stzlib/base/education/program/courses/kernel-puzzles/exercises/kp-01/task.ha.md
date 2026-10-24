### Wasa 1 · Ninki biyu

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Jeri `a` yana da lambobi 4,000: 0, 1, 2, 3 da sauransu. Rubuta kwaya (kernel) da zai sa ninki
biyu na kowace lamba cikin `c`, ta yadda `c[i] = a[i] * 2` ga kowane abu.

A kan GPU babu madauki (loop). **Zare** daya yana gudu ga kowane abu a lokaci guda, kuma bayaninka
yana faɗin abin da kowane zare ke yi da abin *nasa*: `@a` shi ne `a` na wannan zaren, `@c` shi ne
`c` nasa. Fara daga

    in a
    out c

ka ƙara layin jiki. Har sai ka yi, mai dubawa yana amsa *waiting for your implementation*: wasa
yana farawa ja.

Mai dubawa yana gudanar da kwayarka a kan na'ura ga lambobi 4,000, sannan kuma a kan wani ɓoyayyen
tsari mai wani girma da waɗansu lambobi, ya kwatanta kowane abu da bayanin da yake riƙe. Kwayar da
take amsa daidai kawai inda aka nuna mata ana kama ta a nan. Shirinka yana buga kalma ɗaya ta mai
dubawa.

Gudanar da shi a kan kwamfuta (`rnxc your-file.ring`) ko buɗe shafin kwas a browser mai WebGPU:
bayani ɗaya, hukunci ɗaya.

**Abin da GPU ya yi ba kamar madauki ba:** babu abin da ya faru ɗaya bayan ɗaya. Zaruruwa dubu
huɗu kowanne ya karanta lamba ɗaya ya rubuta lamba ɗaya, a lokaci guda.
