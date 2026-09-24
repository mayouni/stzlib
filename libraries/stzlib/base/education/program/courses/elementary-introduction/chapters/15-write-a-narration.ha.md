# Rubuta labari

*Gabatarwa ta Farko · Babi na 15 · Fasahohi CR-01 "Shin kowane misali a takardata har yanzu yana gudana?", CR-02 "Me zai karye idan na yi kuskure?" da CR-03 "Me ya sa ya ce a'a?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Kowane babi da ka karanta an duba shi ta hanyar gudanar da shi, ɗaki bayan ɗaki, kafin ya kai gare ka.
Wannan babin na ƙarshe yana miƙa maka kayan aiki iri ɗaya: labari wanda kowane ɗakinsa yake gudana, mai
tsaro mai yanayi mai kyau da mara kyau, da hukunci da yake bayyana kansa.

## 1. Labari fayil na rubutu ne mai alkawura

Ɗaki yana yin alkawarin abin da yake bugawa. Mai gudanar da babuka yana gudanar da kowane ɗaki a sabon
tsari ya kwatanta.

```ring
cDoc = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 2" + char(10) + "```" + char(10)
cMini = "t_mini_" + ProcessId() + ".en.md"
write(cMini, cDoc)
oCh = StzChapterQ(cMini, "en")
oCh.Run("")
? oCh.NumberOfCells()
#--> 1
? oCh.AllPromisesKept()
#--> TRUE
```

## 2. Alkawarin da aka karya ana kama shi, ba a ɓoye shi

Takarda ɗaya da alkawari mara daidai. Takardar ba ta zama daidai ta hanyar rubuta ta ba.

```ring
cBroken = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 3" + char(10) + "```" + char(10)
cMini2 = "t_mini2_" + ProcessId() + ".en.md"
write(cMini2, cBroken)
oCh2 = StzChapterQ(cMini2, "en")
oCh2.Run("")
? oCh2.AllPromisesKept()
#--> FALSE
? oCh2.CellKept(1)
#--> FALSE
```

## 3. Mai tsaro yana da yanayi mai kyau da mara kyau

Dubawar da ba za ta iya faɗuwa ba ba ta tabbatar da komai. Mai tsaron da ke ƙasa zai zama ja idan mai
gudanarwa ya taɓa karɓar takardar da ta karye, kuma ja idan ya taɓa ƙin mai kyau.

```ring
? oCh.AllPromisesKept() = 1 and oCh2.AllPromisesKept() = 0
#--> TRUE
remove(cMini)
remove(cMini2)
```

## 4. Hukunci yana bayyana kansa

Mai duba ayyukan wannan darasin abu ɗaya ne. Ba shi alkawari da shiri, kuma yana faɗin abin da ya faru da
kalmomin mai koyo, ba darajar da ake tsammani ba.

```ring
oNo = new stzExerciseCheck("demo", [ "3" ], "? 42", [])
? oNo.Passed()
#--> FALSE
? oNo.Why()
#--> Your program ran, but what it printed is not yet what the task asks. It printed: 42
oYes = new stzExerciseCheck("demo", [ "3" ], "? 1 + 2", [])
? oYes.Why()
#--> Every promise of the exercise was kept when your program ran.
```

{{exercise:ex-15-01}}

{{exercise:ex-15-02}}

{{exercise:ex-15-03}}

## Taƙaitawa

- **Abin da ka cimma:** ka rubuta labari ka gudanar da shi, ka ga an kama alkawari mara daidai, ka rubuta
  mai tsaro mai yanayi mai kyau da mara kyau, ka karanta hukuncin da yake ambaton abin da aka buga ba abin da
  ake tsammani ba.
- **Me ya sa yake da muhimmanci:** takardar da take gudana ba za ta iya kauce wa lambar da take kwatantawa
  ba. Wannan ita ce dokar da kowane shafi na wannan darasin ya bi, kuma yanzu taka ce.
- **Abin da ke tafe:** ayyukan matakai. Ana samun mataki lokacin da aikin naka ya wuce masu tsaronsa.
