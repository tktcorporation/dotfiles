#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "./check_markdown_files.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check_links() {
    npx markdown-link-check@^3 \
        --config markdown-link-check.json \
        --quiet \
        --retry \
        "$file"
}

check_markdown_files check_links
