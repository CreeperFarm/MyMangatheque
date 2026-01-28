#!/bin/bash

# Script to manually update CHANGELOG.md with the current version from pubspec.yaml
# Usage: ./scripts/update_changelog.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Updating CHANGELOG.md...${NC}"

# Get the current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
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
    
    # Create new changelog entry
    NEW_ENTRY="## [$CURRENT_VERSION] - $CURRENT_DATE

### Added
- Version bump to $CURRENT_VERSION

### Changed
- Update version in pubspec.yaml

### Fixed
- Bug fixes and improvements

"
    
    # Insert new entry after the header (before the first version entry)
    if grep -q "## \[" CHANGELOG.md; then
      # Insert before the first version entry
      awk -v new_entry="$NEW_ENTRY" '
        /^## \[/ && !inserted {
          print new_entry
          inserted=1
        }
        {print}
      ' CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md
    else
      # Append to the end of the file
      echo -e "\n$NEW_ENTRY" >> CHANGELOG.md
    fi
    
    echo -e "${GREEN}CHANGELOG.md updated successfully!${NC}"
  fi
fi

echo -e "${GREEN}Done!${NC}"
echo "Please review and update the changelog entries as needed before committing."
