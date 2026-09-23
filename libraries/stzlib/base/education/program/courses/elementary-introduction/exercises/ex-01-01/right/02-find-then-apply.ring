# The mental model, step by step. Prints one item per line.
o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])
o1.RemoveItemsAtPositions( o1.FindDuplicates() )
? o1.Content()
