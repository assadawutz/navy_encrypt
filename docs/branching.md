# Branching strategy

This repository now includes a dedicated **dev** branch that was bootstrapped
from the `main` branch state aligned with the Flutter 3.3.8 toolchain. Use the
following commands to keep both branches in sync when preparing new features or
bug fixes:

```sh
git checkout main
git pull origin main

git checkout dev
git merge --ff-only main
```

Create feature branches off `dev` for day-to-day development and raise pull
requests back into `dev`. When the branch is ready for release, fast-forward the
`main` branch so it continues to track the Flutter 3.3.8-compatible codebase.
