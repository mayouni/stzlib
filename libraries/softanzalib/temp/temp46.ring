load "guilib.ring"

o1 = new QMimeData()
o1.setText("salem")
? o1.hashtml()

? o1.formats().at(0)
? o1.hasFormat("text/plain")

? o1.data("text/plain").data()

o1.setHtml("<h1>Title1</h1>")
? o1.hasHtml()

? o1.formats().at(1)
? o1.data("text/html").data()

/*
setData("text/plain","blablabla")
setText()
setHtml()
setUrls()
setImageData()
setColorData()

data("text/plain")
hasFormat("text/plain")
hasText()
hasHtml()
hasUrls()
hasImage()
and hasColor()
*/
