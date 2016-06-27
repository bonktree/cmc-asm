#!/bin/sh
for f in `$@`; do
    fm="`echo "$f" | sed -e 's|[[:upper:]]*|\L&|g'`"
    mkdir -p "`dirname $fm`"
    mv -v "$f" "${fm}x"
    mv -v "${fm}x" "$fm"
done

