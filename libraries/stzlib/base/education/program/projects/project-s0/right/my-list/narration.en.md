# My list

```ring
o = new stzList([ "mango", "rice", "mango", "okra" ])
? o.NumberOfItems()
#--> 4
```

```ring
? o.ContainsDuplicates()
#--> TRUE
```

```ring
? o.NumberOfDuplicates()
#--> 1
```

```ring
? @@( o.FindDuplicates() )
#--> [ 3 ]
```

```ring
? @@( o.DuplicatesRemoved() )
#--> [ "mango", "rice", "okra" ]
```
