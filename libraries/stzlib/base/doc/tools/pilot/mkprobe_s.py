import sys, subprocess, re
# usage: python mkprobe_s.py probes.txt   (one probe per line: statements that end by setting x)
# helpers: S() "banana", T() "the quick fox", U() "<<a>> and <<b>>", V() "Banana Split"
S = "C:/Users/ASUSV3~1/AppData/Local/Temp/claude/D--GitHub-stzlib/9a0dccae-8274-4800-8870-3865850d08f5/scratchpad/"
lines = [re.sub(r"\b(S|T|U|V)\(\)", r"zz\1()", l.rstrip("\n"))
         for l in open(sys.argv[1], encoding="utf-8") if l.strip() and not l.startswith("#")]
out = ['load "D:/GitHub/_wtd/libraries/stzlib/stzlib.ring"']
for l in lines:
    lab = l.replace('"', "`").replace("\\", "/")
    out.append("zzPr(\"%s\", '%s')" % (lab, l.replace("'", "`")))
out.append('''func zzPr(cLabel, cCode)
	x = ""
	try
		eval(cCode)
		if isList(x)
			? cLabel + " => " + @@(x)
		else
			? cLabel + " => " + x
		ok
	catch
		? cLabel + " !! " + cCatchError
	done
func zzS()
	return new stzString("banana")
func zzT()
	return new stzString("the quick fox")
func zzU()
	return new stzString("<<a>> and <<b>>")
func zzV()
	return new stzString("Banana Split")''')
open(S + "probe_run_s.ring", "w", encoding="utf-8").write("\n".join(out) + "\n")
p = subprocess.run(["ring", S + "probe_run_s.ring"], capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=600)
print(p.stdout[-16000:] + p.stderr[-800:])
