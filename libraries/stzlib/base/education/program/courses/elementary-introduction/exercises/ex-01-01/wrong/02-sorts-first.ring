# Each dish once -- but no longer in the order it was first ordered.
aOrders = sort([ "tea", "rice", "tea", "fish", "rice", "tea" ])
? @@( StzListQ(aOrders).DuplicatesRemoved() )
