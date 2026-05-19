load "test_stubs.ring"
? "StzFind in string: " + StzFind("hello world", "world")
? "StzFind not found: " + StzFind("hello world", "xyz")
? "StzFind in list: " + StzFind(["a","b","c"], "b")
? "StzReplace test: " + StzReplace("hello world hello", "hello", "HI")
? "ring_find compat: " + ring_find("abc def", "def")
? "ring_substr2 compat: " + ring_substr2("abc def abc", "abc", "XY")
