#!/usr/bin/env python
"""An INDEPENDENT builder for the PI-SPI interoperable QR payload, and the check that keeps the
guard's vectors honest.

stzPispiQr builds the payload in Ring. A guard that compared Ring with itself would prove only
that it is deterministic, so the expected strings in payments_qr_narrated.ring were produced here,
by a second implementation written from the same tag table (the BCEAO's published builder, read
2026-10-05) in a different language, with Python's own CRC-16/CCITT-FALSE (binascii.crc_hqx).

    python payments_qr_vectors.py            # prints the VECTOR lines
    python payments_qr_vectors.py --check    # fails if the guard's VECTOR lines differ

What this proves is that Ring and Python AGREE on the string. That the BCEAO's phones accept it is
a different claim, and only a person scanning it can make it: see the guard's last scene.
"""
import binascii
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GUARD = os.path.join(HERE, "payments_qr_narrated.ring")

ALIAS = "3497a720-ab11-4973-9619-534e04f263a1"


def tlv(i, v):
    return "%s%02d%s" % (i, len(v), v)


def build(alias, country, channel, label, amount=None, purpose=None, custom=()):
    acct = tlv("00", "int.bceao.pi") + tlv("01", alias)
    body = tlv("00", "01") + tlv("36", acct) + tlv("52", "0000") + tlv("53", "952")
    if amount is not None:
        body += tlv("54", str(amount))
    body += tlv("58", country) + tlv("59", "X") + tlv("60", "X")
    add = tlv("05", label) + tlv("11", channel)
    if purpose:
        add += tlv("12", purpose)
    for k, v in sorted(custom):
        add += tlv(k, v)
    body += tlv("62", add) + "6304"
    return body + "%04X" % binascii.crc_hqx(body.encode("ascii"), 0xFFFF)


VECTORS = [
    ("static-no-amount", build(ALIAS, "CI", "000", "CAISSE_A01")),
    ("static-fixed", build(ALIAS, "CI", "000", "Produit-ABC-123654", 1500)),
    ("dynamic", build(ALIAS, "CI", "400", "Tx-20251112-055052-001", 82500)),
    ("dynamic-niger-purpose-custom", build(ALIAS, "NE", "400", "VENTE-2026-001", 18500, "Panier-001",
                                          [("ZZ", "b"), ("AA", "a"), ("07", "x")])),
]


def main():
    lines = ["# VECTOR %s %s" % (n, p) for n, p in VECTORS]
    if "--check" not in sys.argv:
        print("\n".join(lines))
        return 0
    text = open(GUARD, encoding="utf-8").read()
    found = re.findall(r"^# VECTOR (\S+) (\S+)$", text, flags=re.M)
    ok = found == VECTORS
    for n, p in VECTORS:
        if (n, p) not in found:
            print("guard lacks or differs on", n, p)
    print("%d vectors, %s" % (len(VECTORS), "ALL AGREE" if ok else "FAILED"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
