#!/usr/bin/env python
"""Runs the chapter 'Getting Paid and Paying' and compares what it prints.

The chapter is a narration: every ```ring block is real and every `#-->` is what the block
printed. This is the run that keeps that true, the same harness that runs the charter's
examples, pointed at the chapter.

    cd libraries/stzlib/base/test/system && python payments_chapter.py

Exit status 0 when every printed value is what the chapter says.
"""
import os
import sys

import charter_examples

HERE = os.path.dirname(os.path.abspath(__file__))
CHAPTER = os.path.normpath(os.path.join(HERE, "..", "..", "doc", "narrations",
                                        "stz-getting-paid-and-paying-narration.md"))

if __name__ == "__main__":
    sys.exit(charter_examples.main(CHAPTER))
