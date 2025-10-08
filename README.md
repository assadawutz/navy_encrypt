# navy_encrypt

This project is pinned to **Flutter 3.3.8** and **OpenJDK 17** via
[FVM](https://fvm.app/). Using the FVM-managed binaries keeps `flutter` and
`dart` invocations consistent across macOS, Windows, and Linux environments.

```sh
# install FVM once (https://fvm.app/docs/getting_started/installation)
pub global activate fvm

# run Flutter and Dart through FVM for every command
fvm flutter pub get
fvm flutter test
fvm dart run tool/some_script.dart
```

After `fvm install`, the desired SDK version is cached under `.fvm/flutter_sdk`
and ignored from version control. Developers can still use the globally
installed Flutter CLI, but the recommended workflow is to always call `fvm
flutter …` or `fvm dart …`.

## Manual QA

- [ ] Perform a watermark-only run (leave encryption disabled, apply a watermark), then use the share action on the result screen and confirm the shared file includes the new watermark rather than the original asset.

## Encryption QA

- [ ] Encrypt the same source file twice with the same password and confirm the resulting `.enc` files differ in size or content (random IVs ensure uniqueness while both decrypt back to the original file).
- [ ] Decrypt an older `.enc` file created before the random-IV update to confirm legacy payloads without IV metadata are still readable.
