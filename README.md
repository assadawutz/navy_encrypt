# navy_encrypt
flutter 3.3.8 openjdk@17

## Manual QA

- [ ] Perform a watermark-only run (leave encryption disabled, apply a watermark), then use the share action on the result screen and confirm the shared file includes the new watermark rather than the original asset.

## Encryption QA

- [ ] Encrypt the same source file twice with the same password and confirm the resulting `.enc` files differ in size or content (random IVs ensure uniqueness while both decrypt back to the original file).
- [ ] Decrypt an older `.enc` file created before the random-IV update to confirm legacy payloads without IV metadata are still readable.
