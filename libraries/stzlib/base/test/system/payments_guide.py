#!/usr/bin/env python
"""Runs the application developer's guide to payments and compares what it prints.

The guide (docs/payments-guide.md at the root of the repository) is a path an application
developer follows top to bottom. Every ```ring block in it is real and every `#-->` is what
the block printed; blocks marked ```ring live talk to a real hub and are never run here.
This is the charter harness, pointed at the guide.

    cd libraries/stzlib/base/test/system && python payments_guide.py
"""
import os
import sys

import charter_examples

HERE = os.path.dirname(os.path.abspath(__file__))
GUIDE = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "..", "docs", "payments-guide.md"))

if __name__ == "__main__":
    sys.exit(charter_examples.main(GUIDE))
