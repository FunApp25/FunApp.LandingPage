#!/usr/bin/env bash
set -euo pipefail
test ! -e build/web/CNAME
grep -Fq 'https://staging.funapp.world/' build/web/index.html
grep -Fq 'noindex, nofollow, noarchive' build/web/index.html
grep -Fq 'Disallow: /' build/web/robots.txt
grep -Fq 'X-Robots-Tag: noindex, nofollow, noarchive' build/web/_headers
