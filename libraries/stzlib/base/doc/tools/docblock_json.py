#!/usr/bin/env python3
"""Turn a docs_<class>.py (a DOC dict, easier to quote than JSON) into docs_<class>.json.

    python docblock_json.py docs_stzNumber.py docs_stzNumber.json
"""
import json, sys, runpy

ns = runpy.run_path(sys.argv[1])
json.dump(ns["DOC"], open(sys.argv[2], "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print(len(ns["DOC"]["entries"]), "entries ->", sys.argv[2])
