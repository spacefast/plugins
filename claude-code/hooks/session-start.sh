#!/bin/sh
if test -f .spacefast/space.json; then
  printf '%s\n' 'Spacefast project marker found. Use the Spacefast skill to read .spacefast/space.json and preserve its existing link. Treat .spacefast/state.json as credential material: never print, commit, or archive it. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user'\''s existing publication intent and approval rules.'
fi
