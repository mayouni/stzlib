load "stzlib.ring"

# In Softanza you get get the unicode number of a char by saying:
? Unicode("鶊")
# when you have that code, you can pass it as an imput to a stzChar
# char object to get the char:
? StzCharQ(40330).Content() #--> 鶊

# If you are curious to know how I made it internally inside the
# Unicode() function, then fellow the following discussion...

# First we create the QChar from whatever a decimal unicode could be

oChar = new QChar(40220) # the char "鴜" coded on 3 bytes

# Second, we create a QString from that QChar

oStr = new QString2()
oStr.append_2(oChar)

# Third, we use toUtf8() on QString to get a QByteArray as a result,
# and then we call data() method on it to get the string with our "鴜"

? oStr.ToUtf8().data()
#--> 鶊
