#!/bin/sh

# Check for the debug flag.
DEBUG_MODE=false
if [ "$1" = "--debug" ]; then
    DEBUG_MODE=true
fi

# Compile every .ts file in the ./static/ts folder.
echo "Compiling TypeScript files in ./views/static/ts..."
for file in ./views/static/ts/*.ts; do
    # Derive the output filename by replacing the .ts extension with .js
    outfile="./views/static/js/$(basename "${file}" .ts).js"
    echo "Compiling ${file} -> ${outfile}"

    bun build "${file}" --outfile="${outfile}" --format=esm
    if [ $? -ne 0 ]; then
        echo "Build failed for ${file}."
        exit 1
    fi
done

echo "All TypeScript files compiled successfully."

# Start your Odin program with or without debug mode.
echo "Starting Odin program..."
if [ "$DEBUG_MODE" = true ]; then
    odin run . -debug
else
    odin run .
fi