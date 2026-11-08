n = 300000
a = list(n)
for i = 1 to n  a[i] = i % 7  next
t = clock()
r = []
for i = 1 to n  if a[i] > 3  r + i  ok  next
? "inline ms " + ((clock() - t) * 1000 / clockspersecond()) + "  hits " + len(r)
f = func x { return x > 3 }
t = clock()
r = []
for i = 1 to n  if call f(a[i])  r + i  ok  next
? "lambda ms " + ((clock() - t) * 1000 / clockspersecond()) + "  hits " + len(r)
