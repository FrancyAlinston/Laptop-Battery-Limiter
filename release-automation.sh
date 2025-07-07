#!/bin/bash

# Release Automation Script for ASUS Battery Limiter v2.0.0
# This script automates the final release steps after authentication is set up

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ASUS Battery Limiter v2.0.0 Release Automation${NC}"
echo -e "${BLUE}=================================================${NC}\n"

# Check if we're in the right directory
if [[ ! -f "battery-indicator" || ! -f "FINAL_SUMMARY.md" ]]; then
    echo -e "${RED}❌ Error: Not in the correct project directory${NC}"
    echo "Please run this script from the Battery-Limiter project root."
    exit 1
fi

# Check git status
echo -e "${YELLOW}📋 Checking git status...${NC}"
if ! git status --porcelain | grep -q '^$'; then
    if git status | grep -q "Your branch is ahead"; then
        echo -e "${GREEN}✅ Local commit ready to push${NC}"
    else
        echo -e "${RED}❌ Working directory not clean or no commits ready${NC}"
        git status
        exit 1
    fi
else
    echo -e "${RED}❌ No commits ready to push${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check authentication
echo -e "\n${YELLOW}🔐 Testing git authentication...${NC}"
if git ls-remote origin >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Git authentication working${NC}"
else
    echo -e "${RED}❌ Git authentication failed${NC}"
    echo "Please set up authentication first. See PUSH_INSTRUCTIONS.md"
    exit 1
fi

# Push changes
echo -e "\n${YELLOW}📤 Pushing changes to remote repository...${NC}"
if git push origin main; then
    echo -e "${GREEN}✅ Changes pushed successfully${NC}"
else
    echo -e "${RED}❌ Failed to push changes${NC}"
    exit 1
fi

# Create and push tag
echo -e "\n${YELLOW}🏷️  Creating and pushing release tag...${NC}"
if git tag -a v2.0.0 -m "Release v2.0.0: Ubuntu Native Updater Integration" 2>/dev/null; then
    echo -e "${GREEN}✅ Tag v2.0.0 created${NC}"
else
    echo -e "${YELLOW}⚠️  Tag v2.0.0 already exists locally${NC}"
fi

if git push origin v2.0.0; then
    echo -e "${GREEN}✅ Tag pushed successfully${NC}"
else
    echo -e "${RED}❌ Failed to push tag${NC}"
    exit 1
fi

# Build .deb package
echo -e "\n${YELLOW}📦 Building .deb package...${NC}"
if [[ -x "./build-deb.sh" ]]; then
    if ./build-deb.sh; then
        echo -e "${GREEN}✅ .deb package built successfully${NC}"
        if [[ -f "asus-battery-limiter_2.0.0_all.deb" ]]; then
            echo -e "${GREEN}📦 Package: asus-battery-limiter_2.0.0_all.deb${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to build .deb package${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  build-deb.sh not found or not executable${NC}"
fi

# Summary
echo -e "\n${BLUE}🎉 Release Process Complete!${NC}"
echo -e "${BLUE}=========================${NC}"
echo -e "${GREEN}✅ Changes pushed to GitHub${NC}"
echo -e "${GREEN}✅ Release tag v2.0.0 created${NC}"
echo -e "${GREEN}✅ Ready for GitHub release creation${NC}"

echo -e "\n${YELLOW}📋 Next Steps:${NC}"
echo "1. Go to: https://github.com/FrancyAlinston/Laptop-Battery-Limiter/releases"
echo "2. Click 'Draft a new release'"
echo "3. Choose tag: v2.0.0"
echo "4. Release title: 'v2.0.0: Ubuntu Native Updater Integration'"
echo "5. Copy description from FINAL_SUMMARY.md"
echo "6. Attach asus-battery-limiter_2.0.0_all.deb if built"
echo "7. Publish release"

echo -e "\n${GREEN}🎯 Mission Accomplished!${NC}"
echo -e "${GREEN}The application can now fetch updates from Ubuntu's native updater!${NC}"

# Optional: Open GitHub releases page
if command_exists xdg-open; then
    echo -e "\n${YELLOW}🌐 Opening GitHub releases page...${NC}"
    xdg-open "https://github.com/FrancyAlinston/Laptop-Battery-Limiter/releases/new?tag=v2.0.0" >/dev/null 2>&1 &
fi
