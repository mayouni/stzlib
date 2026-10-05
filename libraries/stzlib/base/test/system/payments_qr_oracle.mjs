// The BCEAO's own SDK, held against stzPispiQr.
//
// payments_qr_narrated.ring proves that Ring and an independent Python builder AGREE on four strings.
// Neither is the BCEAO's. This script builds the same four with the BCEAO's published JavaScript SDK
// (@pi-spi/qrcode, MIT) and compares them with the strings in the guard. A person runs it:
//
//     npm install @pi-spi/qrcode
//     node payments_qr_oracle.mjs
//
// The desk that wrote this does not install packages from a registry, so the script has NOT been run
// by it: the first run is also the first test of the script. It was written from the SDK's source as
// published on the portal (createQrPayload(input, { additionalData }) returning { payload }). If the
// export names differ in the installed version, the failure is an import error, never a false PASS.
//
// A DIFFERENCE here is a finding, not a bug in either side: the portal's own validator placeholder
// begins with a tag 01 that the SDK's builder does not emit, and the two have never been reconciled.
import { readFileSync } from "node:fs";
import { createQrPayload } from "@pi-spi/qrcode";

const ALIAS = "3497a720-ab11-4973-9619-534e04f263a1";
const here = new URL(".", import.meta.url);
const guard = readFileSync(new URL("payments_qr_narrated.ring", here), "utf8");
const want = Object.fromEntries([...guard.matchAll(/^# VECTOR (\S+) (\S+)$/gm)].map(m => [m[1], m[2]]));

const cases = {
  "static-no-amount": [{ alias: ALIAS, countryCode: "CI", qrType: "STATIC", referenceLabel: "CAISSE_A01" }, {}],
  "static-fixed": [{ alias: ALIAS, countryCode: "CI", qrType: "STATIC", referenceLabel: "Produit-ABC-123654", amount: 1500 }, {}],
  "dynamic": [{ alias: ALIAS, countryCode: "CI", qrType: "DYNAMIC", referenceLabel: "Tx-20251112-055052-001", amount: 82500 }, {}],
  "dynamic-niger-purpose-custom": [
    { alias: ALIAS, countryCode: "NE", qrType: "DYNAMIC", referenceLabel: "VENTE-2026-001", amount: 18500 },
    { additionalData: { purposeOfTransaction: "Panier-001", custom: { ZZ: "b", AA: "a", "07": "x" } } },
  ],
};

let bad = 0;
for (const [name, [input, options]] of Object.entries(cases)) {
  const got = createQrPayload(input, options).payload;
  const same = got === want[name];
  if (!same) { bad++; console.log(`DIFFERS ${name}\n  sdk:   ${got}\n  stzlib:${want[name]}`); }
  else console.log(`same    ${name}`);
}
console.log(bad === 0 ? "ALL FOUR EQUAL THE BCEAO SDK" : `${bad} DIFFER`);
process.exit(bad === 0 ? 0 : 1);
