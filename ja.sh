#!/bin/bash

# Variables

CONFIG_FILE="${1:-build.cfg}"
NEXT=""
CLASSPATH=""
SRC="src"
BUILD="bin"
ENTRY=""
RESOURCES=()
FINAL_NAME="$(basename "$(pwd)").jar"

# Utilities

function fail {
    echo "$(tput setaf 1)$*$(tput sgr0)" >&1
    exit 1
}

# Config parsers

function parse::dep {
    local parts=( $(echo "$1" | tr ':' ' ') )
    local groupID="${parts[0]}"
    local artifactID="${parts[1]}"
    local version="${parts[2]}"
    local classpathEntry="$HOME/.m2/repository/${groupID//.//}/$artifactID/$version/$artifactID-$version.jar"

    if [ ! -z "$CLASSPATH" ]; then
        CLASSPATH="$CLASSPATH:"
    fi
    CLASSPATH="$CLASSPATH$classpathEntry"
}

function parse::src {
    SRC="$1"
}

function parse::build {
    BUILD="$1"
}

function parse::entry {
    ENTRY="$1"
}

function parse::resource {
    RESOURCES+=( "$1" )
}

function parse::finalName {
    FINAL_NAME="$1"
}

# Config reader

if [ ! -f "$CONFIG_FILE" ]; then
    fail "The config file '$CONFIG' could not be found."
fi

while read -r line; do
    if [ ! "$line" ]; then
        continue
    fi

    if [ ! -z "$NEXT" ]; then
        parse::$NEXT "$line"
        NEXT=""
        continue
    fi

    if [ "$line" = "[Dependency]" ]; then
        NEXT=dep
    elif [ "$line" = "[Source]" ]; then
        NEXT=src
    elif [ "$line" = "[Build]" ]; then
        NEXT=build
    elif [ "$line" = "[Entry]" ]; then
        NEXT=entry
    elif [ "$line" = "[Resource]" ]; then
        NEXT=resource
    elif [ "$line" = "[Final name]" ]; then
        NEXT=finalName
    fi

done < "$CONFIG_FILE"

# Pre-build handling

if [ ! -d "$BUILD" ]; then
    mkdir -p "$BUILD"
fi

if [ ! "$ENTRY" ]; then
    fail "You must provide an entry point with an [Entry] option."
fi

# Build command

OPTS=( -sourcepath "$SRC" -d "$BUILD" )
if [ ! -z "$CLASSPATH" ]; then
    OPTS+=( -cp $CLASSPATH )
fi

echo -n "Building... "
javac "${OPTS[@]}" "$SRC/${ENTRY//.//}.java" || fail "Failed to compile."
echo "done"

for resource in "${RESOURCES[@]}"; do
    if [ -d "$resource" ]; then
        cp -r "$resource"/* "$BUILD"
    else
        cp -r "$resource" "$BUILD"
    fi
done


jar -cf "$FINAL_NAME" -C "$BUILD" .
