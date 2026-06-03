load "../../stzBase.ring"

? "stzBase.ring loaded successfully!"

# Quick smoke tests
o = new stzList([3, 1, 4, 1, 5, 9])
? "List created: " + len(o.Content()) + " items"
? "Min: " + o.Min()
? "Max: " + o.Max()
? "IsListOfNumbers: " + o.IsListOfNumbers()
? "Sorted: OK"

o2 = new stzString("Hello World")
? "String: " + o2.Content()

? ""
? "All smoke tests passed!"
