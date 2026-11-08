import os,re,collections
KW=set("if but else for in to step while switch on other try catch done return break continue and or not true false nil is const global use forms profile import def end class from new func load package private next again exit loop see give call get put do case off ok bye".split())
U=re.compile(r'(?<![A-Za-z0-9_@$])_([A-Za-z][A-Za-z0-9]*)_(?![A-Za-z0-9_])')
c=collections.Counter()
for dp,dn,fn in os.walk('' + __import__('sys').argv[1] + ''):
    if '/test' in dp.replace(chr(92),'/'): continue
    for f in fn:
        if f.endswith('.ring'):
            for m in U.finditer(open(os.path.join(dp,f),encoding='utf-8',errors='replace').read()):
                x=m.group(1).lower()
                if x in KW: c[x]+=1
print('stripped _x_ that become a keyword:', sum(c.values()), c.most_common(15))
