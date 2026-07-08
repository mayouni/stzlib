# Intent: Reduce words to their base or root form (lemmatize / stem)

```ring
Q("The children were running happily.").TextQ().Lemmatized()
#--> "The child be run happily."
```

- **Methods:** stzText.Lemmatized, stzText.Lemma, stzText.Stemmed, stzText.AutoLemmatized
- **Tags:** lemmatize, stem, base form, root word, dictionary form, canonical form, normalize
- **See also:** detect-language
