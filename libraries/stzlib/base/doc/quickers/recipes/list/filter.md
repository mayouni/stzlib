# Intent: Keep only the list items that match a condition

```ring
Q([ 1, 2, 3, 4, 5, 6 ]).FilterQ('{ @item > 3 }').Content()
#--> [ 4, 5, 6 ]
```

The condition is a small engine-evaluated expression where `@item` is each element.

- **Methods:** stzList.Filter, stzList.FilterQ
- **Tags:** filter, keep where, select, subset, matching items, pick out, retain
- **See also:** find
