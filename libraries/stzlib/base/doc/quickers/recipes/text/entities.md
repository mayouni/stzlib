# Intent: Find the people, places, and organizations mentioned in text

```ring
Q("Alice met Bob in Paris.").TextQ().NamedEntities()
#--> [ [ "Alice", "PERSON" ], [ "Bob", "PERSON" ], [ "Paris", "LOCATION" ] ]
```

Just the people:

```ring
Q("Alice met Bob in Paris.").TextQ().PersonNames()
#--> [ "Alice", "Bob" ]
```

- **Methods:** stzText.NamedEntities, stzText.PersonNames, stzText.Organizations, stzText.Locations
- **Tags:** entities, who is mentioned, people, places, names, organizations, companies, cities
- **See also:** sentiment
