import os, re, sys, collections
root = sys.argv[1]  # .../libraries/stzlib
W = re.compile(r'@(item|i|char|string|number|prime|pair|list|position|value|nextitem|previousitem|currentitem|key|line|word|cell|row|col|node|j|k)\b', re.I)
U = re.compile(r'(?<![A-Za-z0-9_@$])_[A-Za-z][A-Za-z0-9]*_(?![A-Za-z0-9_])')
KW = ['where_','_where_','_where','_select','_select_','select_','_if','if_','iif','else_','_else','and_','or_','not_','end_','_but','_or','_and','_not','but_','_end','_then','then_','_for','for_','_in','in_','_to','to_','_from','from_','_ok','ok_','_next','next_','_load','load_','_func','func_','_class','class_','_new','new_','_return','return_','_case','case_','_on','on_','_off','off_','_other','other_','_step','step_','_switch','switch_','_do','do_','_again','again_','_while','while_','_exit','exit_','_loop','loop_','_see','see_','_give','give_','_call','call_','_try','try_','_catch','catch_','_done','done_','_import','import_','_private','private_','_package','package_','_def','def_','_put','put_','_get','get_','_change','change_','_bye','bye_','_is','is_','_eval','eval_']
DEF = re.compile(r'^\s*(def|func)\s+([A-Za-z_@][A-Za-z0-9_@]*)\s*\(?', re.I | re.M)
EV = re.compile(r'(?<![A-Za-z0-9_])eval\s*\(', re.I)
def walk(sub, tests):
    for dp, dn, fn in os.walk(os.path.join(root, sub)):
        p = dp.replace('\\','/')
        is_t = '/test/' in p + '/'
        if is_t != tests: continue
        for f in fn:
            if f.endswith('.ring'): yield os.path.join(dp, f)
def count(tests):
    w = collections.Counter(); wf = set(); u = 0; uf = set(); un = collections.Counter(); ev = 0; evf=set()
    kd = collections.Counter(); kdf = collections.defaultdict(set)
    files = list(walk('base', tests)) + ([] if tests else list(walk('core', False)))
    for fp in files:
        try: s = open(fp, encoding='utf-8', errors='replace').read()
        except: continue
        for m in W.finditer(s): w[m.group(1).lower()] += 1; wf.add(fp)
        for m in U.finditer(s): u += 1; uf.add(fp); un[m.group(0).lower()] += 1
        n = len(EV.findall(s)); ev += n
        if n: evf.add(fp)
        for m in DEF.finditer(s):
            name = m.group(2).lower()
            if name in KW or name.endswith('_') and name[:-1] in ('where','select','if','else','and','or','not','end','but','load','for','in','to','from','case','return','new','class','func','do','see','give','call','try','catch','import','while','exit','loop','step','switch','next','other','off','on','again','done','put','get','change','bye','eval','is','then','ok') :
                kd[name] += 1; kdf[name].add(os.path.relpath(fp, root))
    return files, w, wf, u, uf, un, ev, evf, kd, kdf
for tests in (False, True):
    files, w, wf, u, uf, un, ev, evf, kd, kdf = count(tests)
    print('== tests' if tests else '== library (base/ minus test, core/)', len(files), 'files')
    print('W placeholders:', sum(w.values()), 'in', len(wf), 'files;', w.most_common(22))
    print('_x_ tokens:', u, 'in', len(uf), 'files; distinct', len(un), 'top', un.most_common(12))
    print('eval( calls:', ev, 'in', len(evf), 'files')
    print('keyword-dodging defs:', sum(kd.values()), 'distinct', len(kd))
    for k, v in sorted(kd.items(), key=lambda x: -x[1]): print('   ', k, v, sorted(kdf[k])[:4])
