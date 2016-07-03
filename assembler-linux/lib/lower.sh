#!/bin/sh
while read NAME; do
    fm="`echo "$NAME" | sed -e 's|[[:upper:]]*|\L&|g'`"
    mkdir -p "`dirname $fm`"
    mv "$NAME" "${fm}x"
    mv "${fm}x" "$fm"
done

