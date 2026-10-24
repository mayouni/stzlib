### Wasa 6 · Kalli maƙwabtanka

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Jeri `a` na lambobi 4,000 da ke tafiya 0, 7, 1, 8, 2, 9 ... (kowanne `(i * 7) % 13` ne). Rubuta kwayar
da zai sassauta shi: kowane abu ya zama matsakaicin maƙwabcinsa na hagu, kansa da maƙwabcinsa na
dama, `c[i] = (a[i-1] + a[i] + a[i+1]) / 3` -- kuma gefuna biyu, waɗanda ke da maƙwabci ɗaya kaɗai,
an bar su ba a rubuta ba.

Zare na iya karanta WANI abu na shigarwa: `@a[@i - 1]` na baya ne, `@a[@i + 1]` na gaba. A wajen jeri
karatu yana amsa 0, saboda haka gefuna naka ne ka tsare:

    in a
    out c
    guard { @i > 0 and @i < n - 1 }

Ba tare da mai tsaron gefe, ana rubuta gefuna kuma hukunci *mismatch at element 1* ne: gefen farko,
wanda aiki ya ce a bar shi.

**Abin da GPU ya yi ba kamar madauki ba:** kowane zare ya karanta lambobi uku a lokaci ɗaya, kuma
maƙwabtansa suna karanta lambobi ɗaya a lokaci ɗaya; babu wanda ya jira zaren da ya gabata.
