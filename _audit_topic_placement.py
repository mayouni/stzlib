#!/usr/bin/env python3
"""Detect modular test blocks that live in the wrong topic dir.

Heuristic: each block's "subject" is the Softanza class it primarily
exercises. We look at every `new stz<X>(...)`, `Stz<X>Q(...)`, and
`@@( ... .stz<X>... )` occurrence, count them per class, and pick the
one with the highest count. If that class's natural topic is not the
dir the file currently sits in, flag the file.

The output is a per-block recommendation: keep / move-to-<topic> /
ambiguous. Run with --json for machine-readable output.
"""
from __future__ import annotations

import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

TEST = Path('libraries/stzlib/base/test')

# Matches `new stzFoo(`, `StzFooQ(`, `stzFoo.`, `oStzFoo`, etc.
# We deliberately only capture the canonical `stz...` prefix so we
# don't accidentally pick up Ring builtins.
CLASS_RE = re.compile(
    r'\b(?:new\s+|Q\s*\(\s*|\.\s*)?'           # optional prefix
    r'(?:stz|Stz|STZ)([A-Z][A-Za-z0-9]+)\b',   # the type name
)
GLOBAL_FUNC_RE = re.compile(r'\b(?:stz|Stz|STZ)([A-Z][A-Za-z0-9]+)Q?\s*\(')

# Class-name -> topic-dir-name mapping. Most classes drop the 'stz'
# prefix and lowercase. A few are special.
SPECIAL_CLASS_TO_TOPIC = {
    # Wrapping-object forms (Q suffix) collapse to the same topic as
    # the bare class -- StzStringQ tests belong with stzString tests.
    'StringQ': 'string',
    'ListQ': 'list',
    'CharQ': 'char',
    'NumberQ': 'number',
    'DateQ': 'date',
    'TimeQ': 'time',
    'DateTimeQ': 'datetime',
    'TextQ': 'ttext',
    'LocaleQ': 'locale',
    'CountryQ': 'i18n',
    'CurrencyQ': 'currency',
    'HashListQ': 'hashlist',
    'CalendarQ': 'calendar',
    'CounterQ': 'counter',
    'EntityQ': 'entity',
    'RegexQ': 'regex',
    'NamedObjectQ': 'object',
    'IntSeqQ': 'counter',
    'PairQ': 'common',
    'StringCharQ': 'char',
    'StringCharsQ': 'char',
    # Internal helpers used by a top-level class -- their tests belong
    # with the class they help, not in a separate topic.
    'StringChecker': 'string',
    'StringFinder': 'string',
    'StringBounder': 'string',
    'StringReplacer': 'string',
    'StringStripper': 'string',
    'StringComparator': 'string',
    'StringInspector': 'string',
    'StringClassifier': 'string',
    'StringNormalizer': 'string',
    'StringExtractor': 'string',
    'StringMover': 'string',
    'StringTransformer': 'string',
    'StringSplitter': 'splitter',
    'StringChar': 'char',
    'StringChars': 'char',
    'ListChecker': 'list',
    'ListFinder': 'list',
    'ListReplacer': 'list',
    'ListClassifier': 'list',
    'ListComparator': 'list',
    'ListInspector': 'list',
    'ListExtractor': 'list',
    'ListMover': 'list',
    'ListCounter': 'list',
    'ListLeadTrail': 'list',
    'ListRemover': 'list',
    'ListRandom': 'list',
    'ListFlattener': 'list',
    'ListTrimmer': 'list',
    'ListSplitter': 'splitter',
    'ListInString': 'string',
    # Additional string helpers
    'StringContains': 'string',
    'StringList': 'string',
    'StringRemover': 'string',
    'StringCrypto': 'string',
    'StringCaseChanger': 'string',
    'StringInserter': 'string',
    # Common / shared internals
    'StateMachine': 'common',
    'Validator': 'common',
    'ItemCS': 'common',
    'Len': 'common',
    'Bytes': 'common',
    'LanguageQ': 'i18n',
    'Language': 'i18n',
    # Table helpers
    'TableAggregator': 'table',
    'TableSearch': 'table',
    'TableStructure': 'table',
    'TableX': 'tablex',
    # File / IO helpers
    'FileXT': 'file',
    'JSONIsValid': 'json',
    # ListOfPairs subsumed under common (it's a paired-data helper)
    'ListOfPairs': 'common',
    'ListOfPairsQ': 'common',
    # Error / engine internals -- not topic-determining.
    'Raise': None,
    'CharData': 'chardata',
    'String': 'string',
    'List': 'list',
    'Number': 'number',
    'Char': 'char',
    'Date': 'date',
    'Time': 'time',
    'DateTime': 'datetime',
    'TimeLine': 'timeline',
    'Calendar': 'calendar',
    'Duration': 'duration',
    'Text': 'ttext',
    'Counter': 'counter',
    'Regex': 'regex',
    'HashList': 'hashlist',
    'KnowledgeGraph': 'knowledgegraph',
    'Graph': 'graph',
    'GraphEx': 'graphex',
    'GraphPlanner': 'graphplanner',
    'GraphQuery': 'graphquery',
    'Table': 'table',
    'TableX': 'tablex',
    'PivotTable': 'pivottable',
    'PivotTableShow': 'pivottableshow',
    'Tree': 'tree',
    'UUID': 'uuid',
    'CSV': 'csv',
    'JSON': 'json',
    'Object': 'object',
    'Tile': 'tile',
    'Yielder': 'yielder',
    'OrgChart': 'orgchart',
    'Currency': 'currency',
    'Country': 'i18n',
    'Locale': 'locale',
    'Plot': 'plot',
    'Diagram': 'diagram',
    'DiagramBuilder': 'diagrambuilder',
    'DiagramColor': 'diagramcolor',
    'DotCode': 'dotcode',
    'CCode': 'ccode',
    'BaturalCode': 'baturalcode',
    'ExterCode': 'extercode',
    'ExtInC': 'extinc',
    'ExtInPython': 'extinpython',
    'ExtInJS': 'extinjs',
    'ExtInPHP': 'extinphp',
    'ExtInSQL': 'extinsql',
    'ExtInPerl': 'extinperl',
    'ExtInCSharp': 'extincsharp',
    'TaskTimer': 'duration',
    'SubString': 'substring',
    'StringArt': 'stringart',
    'RegexMaker': 'regexmaker',
    'RegexUter': 'regexuter',
    'DataSet': 'dataset',
    'DataWrangler': 'datawrangler',
    'CoeffExtractor': 'coeffextractor',
    'BinaryNumber': 'binarynumber',
    'OctalNumber': 'octalnumber',
    'HexNumber': 'hexnumber',
    'DecimalToBinary': 'decimaltobinary',
    'FastPro': 'fastpro',
    'IntSeq': 'counter',  # IntSeq is the engine handle that backs counter
    'Folder': 'folder',
    'File': 'file',
    'Entity': 'entity',
    'ListOfStrings': 'listofstrings',
    'ListOfStringsQ': 'listofstrings',
    'ListOfNumbers': 'listofnumbers',
    'ListOfNumbersQ': 'listofnumbers',
    'ListOfChars': 'listofchars',
    'ListOfCharsQ': 'listofchars',
    'ListOfBytes': 'listofbytes',
    'ListOfBytesQ': 'listofbytes',
    'ListOfLists': 'listoflists',
    'ListOfEntities': 'listofentities',
    'ListOfHashLists': 'listofhashlists',
    'ListOfTimeLines': 'listoftimelines',
    'List2D': 'list2d',
    'Listex': 'listex',
    'Singular': 'singular',
    'Plural': 'plural',
    'Ordinal': 'ordinal',
    'Adverb': 'adverb',
    'Script': 'script',
    'NamedVars': 'namedvars',
    'NamedObject': 'object',
    'Func': 'func',
    'Char': 'char',
    'ChainOfTruth': 'chainoftruth',
    'ChainOfValue': 'chainofvalue',
    'TimeX': 'timex',
    'Matrex': 'matrex',
    'Grid': 'matrex',
    'Splitter': 'splitter',
    'SortedList': 'sortedlist',
    'ReactiveStream': 'reactivestream',
    'Reactive': 'reactive',
    'ReactiveTask': 'reactivetask',
    'ReactiveObject': 'reactiveobject',
    'ReactiveTimer': 'reactivetimer',
    'AppServer': 'appserver',
    'AppServerCluster': 'appservercluster',
    'Cluster': 'cluster',
    'SystemCall': 'systemcall',
    'SystemCallData': 'systemcalldata',
    'SystemFunc': 'systemfunc',
    'Html': 'html',
    'LinearSolver': 'linearsolver',
    'Pair': 'common',
    'PairOfNumbers': 'common',
}


def expected_topic(class_name: str) -> str | None:
    # Engine-internal types are never topic-determining.
    if class_name.startswith('Engine'):
        return None
    if class_name in SPECIAL_CLASS_TO_TOPIC:
        return SPECIAL_CLASS_TO_TOPIC[class_name]
    return class_name.lower()


def classes_in(text: str) -> Counter[str]:
    bag: Counter[str] = Counter()
    for m in CLASS_RE.finditer(text):
        bag[m.group(1)] += 1
    for m in GLOBAL_FUNC_RE.finditer(text):
        bag[m.group(1)] += 1
    return bag


def audit_file(f: Path):
    text = f.read_text(encoding='utf-8', errors='replace')
    bag = classes_in(text)
    if not bag:
        return None
    # Drop the "noise" types that appear in almost every test
    NOISY = {'Base', 'Type', 'TYPE', 'Q'}
    for n in NOISY:
        bag.pop(n, None)
    if not bag:
        return None
    dominant, count = bag.most_common(1)[0]
    if count < 3:
        return None  # require a stronger signal: at least 3 mentions
    expected = expected_topic(dominant)
    if not expected:
        return None
    current_topic = f.parent.name
    if current_topic == expected:
        return None
    # Also require dominance: the top class must be 1.5x the second one
    # so files that mix two classes 50/50 aren't reassigned.
    if len(bag) > 1:
        second_count = bag.most_common(2)[1][1]
        if count < second_count * 1.5:
            return None
    # Don't move into a topic that doesn't exist as a dir
    if not (TEST / expected).is_dir():
        return {'file': str(f.relative_to(TEST)), 'dominant': dominant,
                'count': count, 'current': current_topic,
                'expected': expected, 'note': 'expected dir missing'}
    return {'file': str(f.relative_to(TEST)), 'dominant': dominant,
            'count': count, 'current': current_topic, 'expected': expected}


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    results = []
    for f in TEST.rglob('*.ring'):
        rel = f.relative_to(TEST)
        if len(rel.parts) != 2:
            continue
        if rel.parts[0].startswith('_'):
            continue
        r = audit_file(f)
        if r:
            results.append(r)

    if '--json' in sys.argv:
        json.dump(results, sys.stdout, indent=2)
        sys.stdout.write('\n')
        return
    by_current = defaultdict(list)
    for r in results:
        by_current[r['current']].append(r)
    print(f'misplaced: {len(results)} block(s) across {len(by_current)} topic dirs')
    for topic, rows in sorted(by_current.items(), key=lambda kv: -len(kv[1])):
        print(f'\n--- in {topic}/  ({len(rows)} misplaced) ---')
        # Group by expected target
        by_target = defaultdict(list)
        for r in rows:
            by_target[r['expected']].append(r)
        for target, items in sorted(by_target.items(),
                                    key=lambda kv: -len(kv[1])):
            print(f'   -> should go to {target}/  ({len(items)}):')
            for item in items[:5]:
                print(f'      {Path(item["file"]).name}  '
                      f'(dominant Stz{item["dominant"]} x{item["count"]})')
            if len(items) > 5:
                print(f'      ... and {len(items) - 5} more')


if __name__ == '__main__':
    main()
