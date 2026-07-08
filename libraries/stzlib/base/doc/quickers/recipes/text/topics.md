# Intent: Find the main topics or key phrases a text is about

```ring
Q("Machine learning models require large training datasets and careful evaluation.").TextQ().KeyPhrases(2)
#--> [ "Machine learning models require large training datasets", "careful evaluation" ]
```

- **Methods:** stzText.KeyPhrases, stzText.RankedKeywords, stzText.TopKeyPhrase
- **Tags:** topics, themes, subjects, key phrases, keywords, what it is about, main points
- **See also:** summarize
