#!/bin/bash
# Usage: ./bump_version.sh <type>
# <type> = patch | minor | major | alpha | rc | release

VERSION_FILE="VERSION"

# Initialize version file if missing
if [ ! -f "$VERSION_FILE" ]; then
    echo "0.1.0" > $VERSION_FILE
fi

CURRENT=$(cat $VERSION_FILE)
echo "Current version: $CURRENT"

# Split version into components
IFS='.-' read -r MAJOR MINOR PATCH LABEL NUM <<< "$CURRENT"

case "$1" in
    patch)
        PATCH=$((PATCH+1))
        NEW="$MAJOR.$MINOR.$PATCH"
        ;;
    minor)
        MINOR=$((MINOR+1))
        PATCH=0
        NEW="$MAJOR.$MINOR.$PATCH"
        ;;
    major)
        MAJOR=$((MAJOR+1))
        MINOR=0
        PATCH=0
        NEW="$MAJOR.$MINOR.$PATCH"
        ;;
    alpha)
        if [ "$LABEL" == "alpha" ]; then
            NUM=$((NUM+1))
        else
            NUM=1
        fi
        NEW="$MAJOR.$MINOR.$PATCH-alpha.$NUM"
        ;;
    rc)
        if [ "$LABEL" == "rc" ]; then
            NUM=$((NUM+1))
        else
            NUM=1
        fi
        NEW="$MAJOR.$MINOR.$PATCH-rc.$NUM"
        ;;
    release)
        NEW="$MAJOR.$MINOR.$PATCH"
        ;;
    *)
        echo "Usage: $0 {patch|minor|major|alpha|rc|release}"
        exit 1
        ;;
esac

# Update version file
echo $NEW > $VERSION_FILE
echo "New version: $NEW"
