#!/bin/bash

# Script to manually update CHANGELOG.md with the current version from pubspec.yaml
# Usage: ./scripts/update_changelog.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Updating CHANGELOG.md...${NC}"

# Check if pubspec.yaml exists
if [ ! -f pubspec.yaml ]; then
  echo -e "${RED}Error: pubspec.yaml not found!${NC}"
  echo "Please run this script from the root of the project."
  exit 1
fi

# Get the current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')

# Check if version was found
if [ -z "$CURRENT_VERSION" ]; then
  echo -e "${RED}Error: Could not find version in pubspec.yaml${NC}"
  exit 1
fi

echo "Current version: $CURRENT_VERSION"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Check if CHANGELOG.md exists
if [ ! -f CHANGELOG.md ]; then
  echo -e "${YELLOW}CHANGELOG.md not found. Creating new file...${NC}"
  cat > CHANGELOG.md << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [$CURRENT_VERSION] - $CURRENT_DATE

### Added
- Initial changelog setup

### Changed
- Version set to $CURRENT_VERSION
EOF
  echo -e "${GREEN}CHANGELOG.md created successfully!${NC}"
else
  # Check if the version already exists in the changelog
  if grep -q "## \[$CURRENT_VERSION\]" CHANGELOG.md; then
    echo -e "${YELLOW}Version $CURRENT_VERSION already exists in CHANGELOG.md${NC}"
    echo "Please manually update the changelog entry if needed."
  else
    echo -e "${YELLOW}Adding new version entry to CHANGELOG.md...${NC}"

    # Create new changelog entry in a temporary file
    cat > changelog_entry.tmp << EOF
## [$CURRENT_VERSION] - $CURRENT_DATE

### Added
- Version bump to $CURRENT_VERSION

### Changed
- Update version in pubspec.yaml

### Fixed
- Bug fixes and improvements

EOF

    # Insert new entry after the header (before the first version entry)
    if grep -q "## \[" CHANGELOG.md; then
      # Insert before the first version entry
      awk '
        /^## \[/ && !inserted {
          while ((getline line < "changelog_entry.tmp") > 0) {
            print line
          }
          close("changelog_entry.tmp")
          inserted=1
        }
        {print}
      ' CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md
    else
      # Append to the end of the file
      cat changelog_entry.tmp >> CHANGELOG.md
    fi

    # Cleanup
    rm -f changelog_entry.tmp

    echo -e "${GREEN}CHANGELOG.md updated successfully!${NC}"
  fi
fi

echo -e "${GREEN}Done!${NC}"
echo "Please review and update the changelog entries as needed before committing."
