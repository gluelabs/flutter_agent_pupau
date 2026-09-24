#!/usr/bin/env bash
# Publishes the current internal `main` to the public GitHub remote as a
# clean snapshot with the SSE debug tooling stripped out — regenerated
# from scratch every run, never merged, so there's nothing to keep in sync.
#
# Requires a `github` remote to be configured:
#   git remote add github <public-repo-url>
set -euo pipefail

REMOTE="github"
DEBUG_DIR="example/lib/debug"

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  echo "error: no '$REMOTE' remote configured. Run:" >&2
  echo "  git remote add $REMOTE <public-repo-url>" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree not clean — commit or stash before publishing." >&2
  exit 1
fi

git checkout main
git checkout -B publish-snapshot

# Whole-directory removal: nothing in here should ever reach the public repo.
git rm -r --quiet "$DEBUG_DIR"

# Partial removal: strip everything between BEGIN-DEBUG-ONLY/END-DEBUG-ONLY
# marker comments, wherever they appear in the tree.
grep -rl "BEGIN-DEBUG-ONLY" --include="*.dart" . | while read -r f; do
  sed -i '' '/BEGIN-DEBUG-ONLY/,/END-DEBUG-ONLY/d' "$f"
  git add "$f"
done

# Drop the debug-only dependency (only needed by the now-removed screen).
sed -i '' '/file_picker:/d' example/pubspec.yaml
git add example/pubspec.yaml

git commit -m "Public release snapshot (debug tooling excluded)"

echo
echo "Snapshot built on 'publish-snapshot'. Review it before pushing:"
echo "  git diff main publish-snapshot"
echo
echo "When ready:"
echo "  git push --force $REMOTE publish-snapshot:main"
echo
echo "Then clean up:"
echo "  git checkout main && git branch -D publish-snapshot"
