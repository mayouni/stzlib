load "guilib.ring"

// Including QFileInfo() features to stzFile

o1 = new QFileInfo()
o1.setFile("abc.txt")

oLocale = new QLocale("ar_TN")

oDateTime = o1.lastmodified()
? oDateTime.toLocaltime().toString("hh:mm:ss")
? oDateTime.toString("dd/MM/yyyy")

/* possible formats
	dd.MM.yyyy	21.05.2001
	ddd MMMM d yy	Tue May 21 01
	hh:mm:ss.zzz	14:13:09.120
	hh:mm:ss.z	14:13:09.12
	h:m:s ap	2:13:9 pm
If the datetime is invalid, an empty string will be returned.
*/



