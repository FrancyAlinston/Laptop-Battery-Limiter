#!/bin/bash

# Universal Battery Limiter - Workflow Validation Script
# Tests and validates the GitHub Actions workflow after branding fixes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔍 Universal Battery Limiter - Workflow Validation"
echo "================================================="

# Check if we're in the correct repository
if [ ! -f "build-deb.sh" ] || [ ! -d ".github/workflows" ]; then
    print_colored $RED "❌ This script must be run from the repository root with .github/workflows/ directory"
    exit 1
fi

# Function to validate YAML syntax
validate_yaml() {
    local file=$1
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_colored $GREEN "  ✓ $file - Valid YAML syntax"
            return 0
        else
            print_colored $RED "  ✗ $file - Invalid YAML syntax"
            return 1
        fi
    else
        print_colored $YELLOW "  ? $file - Cannot validate (python3 not available)"
        return 0
    fi
}

# Function to check workflow file content
validate_workflow_content() {
    local file=$1
    local issues=0

    # Check for universal naming
    if grep -q "universal-battery-limiter" "$file"; then
        print_colored $GREEN "  ✓ Uses universal-battery-limiter package naming"
    else
        print_colored $RED "  ✗ Still contains old package naming"
        ((issues++))
    fi

    # Check for ASUS branding
    if grep -qi "asus" "$file"; then
        print_colored $RED "  ✗ Still contains ASUS branding"
        grep -n -i "asus" "$file" | head -3
        ((issues++))
    else
        print_colored $GREEN "  ✓ No ASUS branding found"
    fi

    # Check for correct artifact patterns
    if grep -q "universal-battery-limiter_\*.deb" "$file"; then
        print_colored $GREEN "  ✓ Correct artifact pattern"
    else
        print_colored $RED "  ✗ Incorrect artifact pattern"
        ((issues++))
    fi

    return $issues
}

# Function to test build script
test_build_script() {
    print_colored $YELLOW "🔨 Testing build script..."
    
    if [ ! -f "build-deb.sh" ]; then
        print_colored $RED "  ✗ build-deb.sh not found"
        return 1
    fi

    if [ ! -x "build-deb.sh" ]; then
        print_colored $RED "  ✗ build-deb.sh not executable"
        return 1
    fi

    # Check build script content
    if grep -q "universal-battery-limiter" build-deb.sh; then
        print_colored $GREEN "  ✓ build-deb.sh uses universal naming"
    else
        print_colored $RED "  ✗ build-deb.sh still uses old naming"
        return 1
    fi

    # Test dry run of package building (without actually building)
    print_colored $BLUE "  🧪 Testing package build dependencies..."
    if command -v dpkg-deb >/dev/null 2>&1; then
        print_colored $GREEN "  ✓ dpkg-deb available"
    else
        print_colored $YELLOW "  ? dpkg-deb not available (needed for building)"
    fi

    return 0
}

# Function to validate all scripts
validate_scripts() {
    print_colored $YELLOW "📝 Validating scripts for universal branding..."
    local issues=0

    for script in battery-cli battery-limit battery-gui battery-indicator set-charge-limit.sh install.sh uninstall.sh; do
        if [ -f "$script" ]; then
            if grep -qi "asus" "$script"; then
                print_colored $RED "  ✗ $script still contains ASUS branding"
                ((issues++))
            else
                print_colored $GREEN "  ✓ $script - No ASUS branding"
            fi
        else
            print_colored $YELLOW "  ? $script not found"
        fi
    done

    return $issues
}

# Function to validate debian package structure
validate_debian_package() {
    print_colored $YELLOW "📦 Validating debian package structure..."
    local issues=0

    if [ -d "debian-package/usr/share/doc/universal-battery-limiter" ]; then
        print_colored $GREEN "  ✓ Correct documentation directory"
    elif [ -d "debian-package/usr/share/doc/asus-battery-limiter" ]; then
        print_colored $RED "  ✗ Old documentation directory still exists"
        ((issues++))
    else
        print_colored $YELLOW "  ? Documentation directory not found"
    fi

    if [ -f "debian-package/etc/sudoers.d/universal-battery-limiter" ]; then
        print_colored $GREEN "  ✓ Correct sudoers file"
    elif [ -f "debian-package/etc/sudoers.d/asus-battery-limiter" ]; then
        print_colored $RED "  ✗ Old sudoers file still exists"
        ((issues++))
    else
        print_colored $YELLOW "  ? Sudoers file not found"
    fi

    # Check DEBIAN control file
    if [ -f "debian-package/DEBIAN/control" ]; then
        if grep -q "universal-battery-limiter" "debian-package/DEBIAN/control"; then
            print_colored $GREEN "  ✓ Control file uses universal naming"
        else
            print_colored $RED "  ✗ Control file uses old naming"
            ((issues++))
        fi
    else
        print_colored $YELLOW "  ? Control file not found"
    fi

    return $issues
}

# Function to create test summary
create_test_summary() {
    local total_issues=$1
    
    print_colored $BLUE "📋 Test Summary:"
    echo "================================"
    
    if [ $total_issues -eq 0 ]; then
        print_colored $GREEN "🎉 All tests passed! The repository is ready for GitHub Actions."
        echo ""
        print_colored $BLUE "Next steps:"
        echo "  1. Commit all changes to git"
        echo "  2. Push to GitHub to trigger workflow"
        echo "  3. Monitor GitHub Actions for successful build"
        echo ""
        return 0
    else
        print_colored $RED "❌ Found $total_issues issues that need to be fixed."
        echo ""
        print_colored $YELLOW "Recommended actions:"
        echo "  1. Run the branding fix script: ./fix-universal-branding-laptop-battery-limiter.sh"
        echo "  2. Run the documentation update script: ./update-documentation.sh"
        echo "  3. Re-run this validation script"
        echo ""
        return 1
    fi
}

# Main validation process
print_colored $YELLOW "🔍 Starting validation process..."
echo ""

total_issues=0

# Validate workflow files
print_colored $YELLOW "1. Validating GitHub Actions workflows..."
for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [ -f "$workflow" ]; then
        echo "  Checking: $workflow"
        validate_yaml "$workflow"
        workflow_issues=$(validate_workflow_content "$workflow")
        ((total_issues += workflow_issues))
    fi
done
echo ""

# Test build script
print_colored $YELLOW "2. Testing build script..."
if ! test_build_script; then
    ((total_issues++))
fi
echo ""

# Validate scripts
print_colored $YELLOW "3. Validating scripts..."
script_issues=$(validate_scripts)
((total_issues += script_issues))
echo ""

# Validate debian package
print_colored $YELLOW "4. Validating debian package structure..."
debian_issues=$(validate_debian_package)
((total_issues += debian_issues))
echo ""

# Create summary
create_test_summary $total_issues
exit $total_issues
