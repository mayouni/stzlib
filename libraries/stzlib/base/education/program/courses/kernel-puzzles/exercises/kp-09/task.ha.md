### Wasa 9 · Ma'ajiyar rukunin

> Fassara ta wucin gadi, ana jiran bitar mai magana da Hausa.

Jeri `a` na lambobi 4,096 (0, 1, 2 ...). Juya shi **a cikin kowane rukuni na 256**: rukuni na
farko ya zama 255, 254 ... 0, na biyu 511, 510 ... 256, haka nan.

Zaruruwa 256 na rukuni ɗaya suna raba ƙaramar ma'ajiya mai sauri wadda zaruruwan wasu rukunoni ba sa
gani. `shared t 256` yana bayyana jeri na lambobi 256 a can. Layin **stage** rubutu ɗaya ne ga kowane
zare; bayansa injin yana sa **shamaki**: babu zaren da zai ci gaba kafin duk zaruruwan rukunin su
rubuta. `@l` shi ne wurin zare a rukuninsa, daga 0 zuwa 255.

    stage { @t[@l] = @a }
    body { @c = @t[255 - @l] }

Bayan shamakin, kowane zare yana karanta wurin da WANI zare ya rubuta. Ba tare da layin stage ba
jerin sifili ne kawai: *mismatch at element 1*. Juya duka jerin kuma abu na farko zai zama 4,095
maimakon 255: *mismatch at element 1* kuma.

Layin stage yana rubuta shamakin a madadinka. A kwayar da aka rubuta da hannu, shamakin da aka manta
shi ne gasar da ke wuce kusan duk gwaje-gwaje kuma ta faɗi a ɗaya.

**Abin da GPU ya yi ba kamar madauki ba:** madaukin da ke juyawa a wuri yana musanya biyu-biyu ɗaya
bayan ɗaya. A nan zaruruwa 256 sun rubuta tare, sun jira sau ɗaya, sun karanta tare.
