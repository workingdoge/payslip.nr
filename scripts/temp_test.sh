#!/bin/bash

# Stop on first error
set -e

# Name of the temporary directory
TEMP_DIR="test_temp"

# Create the temporary directory if it does not exist
[ -d "$TEMP_DIR" ] || mkdir "$TEMP_DIR"

# Copy test files with replacements
find ./test -type f | while read -r file; do
  sed 's/@aztec\/noir-contracts"/@aztec\/noir-contracts\/types"/' "$file" > $TEMP_DIR/$(basename $file)
done

# compile noir contracts
# aztec-cli compile ./contracts --outdir ./artifacts --typescript ./artifacts

# Run Jest in the temporary directory
 node --experimental-vm-modules ./node_modules/jest/bin/jest.js --runInBand

# Uncomment the following line if you want to clean up the temporary directory
rm -rf "$TEMP_DIR"
