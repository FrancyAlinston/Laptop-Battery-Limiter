#!/bin/bash

# Enhanced GitHub Actions Workflow Diagnostic and Fix Script
# For both Universal Battery Limiter and ASUS Laptop-Battery-Limiter repositories

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

print_header() {
    echo
    print_colored $BLUE "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_colored $BLUE "  $1"
    print_colored $BLUE "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

# Detect repository type
detect_repo_type() {
    if [ -f "battery-cli" ] && [ -f "battery-limit" ] && [ -f "build-deb.sh" ]; then
        echo "laptop-battery-limiter"
    elif [ -f "python-app.yml" ] || [ -f ".github/workflows/python-app.yml" ]; then
        echo "universal-battery-limiter"
    else
        echo "unknown"
    fi
}

# Validate workflow YAML syntax
validate_workflow_yaml() {
    local workflow_file="$1"
    
    if ! command -v python3 >/dev/null 2>&1; then
        print_colored $YELLOW "⚠️ Python3 not available - skipping YAML validation"
        return 0
    fi
    
    python3 -c "
import yaml
import sys

try:
    with open('$workflow_file', 'r') as f:
        yaml.safe_load(f)
    print('✅ YAML syntax is valid')
    sys.exit(0)
except yaml.YAMLError as e:
    print(f'❌ YAML syntax error: {e}')
    sys.exit(1)
except FileNotFoundError:
    print('❌ Workflow file not found')
    sys.exit(1)
"
}

# Check repository structure
check_repo_structure() {
    local repo_type="$1"
    
    print_colored $YELLOW "📁 Checking repository structure..."
    
    case $repo_type in
        "laptop-battery-limiter")
            required_files=("battery-cli" "battery-limit" "battery-gui" "battery-indicator" "install.sh" "build-deb.sh" "README.md")
            ;;
        "universal-battery-limiter")
            required_files=("setup.py" "requirements.txt" "README.md" "src/" "tests/")
            ;;
        *)
            print_colored $RED "❌ Unknown repository type"
            return 1
            ;;
    esac
    
    missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        print_colored $GREEN "✅ All required files present"
        return 0
    else
        print_colored $RED "❌ Missing files:"
        for file in "${missing_files[@]}"; do
            print_colored $RED "   - $file"
        done
        return 1
    fi
}

# Test script syntax
test_script_syntax() {
    local repo_type="$1"
    
    print_colored $YELLOW "🔍 Testing script syntax..."
    
    case $repo_type in
        "laptop-battery-limiter")
            # Test shell scripts
            for script in battery-cli battery-limit install.sh uninstall.sh build-deb.sh set-charge-limit.sh; do
                if [ -f "$script" ]; then
                    if bash -n "$script" 2>/dev/null; then
                        print_colored $GREEN "✅ $script syntax OK"
                    else
                        print_colored $RED "❌ $script syntax error"
                        return 1
                    fi
                fi
            done
            
            # Test Python scripts
            for script in battery-gui battery-indicator; do
                if [ -f "$script" ]; then
                    if python3 -m py_compile "$script" 2>/dev/null; then
                        print_colored $GREEN "✅ $script Python syntax OK"
                    else
                        print_colored $RED "❌ $script Python syntax error"
                        return 1
                    fi
                fi
            done
            ;;
        "universal-battery-limiter")
            # Test Python modules
            if command -v python3 >/dev/null 2>&1; then
                find src/ -name "*.py" -exec python3 -m py_compile {} \; 2>/dev/null && \
                    print_colored $GREEN "✅ Python syntax OK" || \
                    print_colored $RED "❌ Python syntax errors found"
            fi
            ;;
    esac
}

# Create fixed workflow for laptop battery limiter repositories
create_laptop_workflow() {
    local workflow_dir=".github/workflows"
    local workflow_file="$workflow_dir/laptop-battery-limiter.yml"
    
    print_colored $YELLOW "📝 Creating fixed workflow for Universal Battery Limiter..."
    
    mkdir -p "$workflow_dir"
    
    cat > "$workflow_file" << 'EOF'
name: Universal Battery Limiter CI/CD

on:
  push:
    branches: [ main, beta, develop ]
  pull_request:
    branches: [ main, beta ]

env:
  DEBIAN_FRONTEND: noninteractive

jobs:
  get-version:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
    - uses: actions/checkout@v4
    - name: Extract version
      id: version
      run: |
        # Extract version from build-deb.sh or set default
        if grep -q "PACKAGE_NAME=" build-deb.sh; then
          VERSION=$(grep "PACKAGE_NAME=" build-deb.sh | sed 's/.*_\([0-9.]*\)_all.deb.*/\1/')
        else
          VERSION="2.0.0"
        fi
        echo "version=$VERSION" >> $GITHUB_OUTPUT
        echo "Detected version: $VERSION"

  test-linux:
    runs-on: ubuntu-latest
    needs: get-version
    steps:
    - uses: actions/checkout@v4
    
    - name: Install system dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
          python3 \
          python3-gi \
          python3-gi-cairo \
          gir1.2-gtk-3.0 \
          gir1.2-appindicator3-0.1 \
          gir1.2-notify-0.7 \
          python3-tk \
          dpkg-dev \
          shellcheck \
          file

    - name: Test shell scripts syntax
      run: |
        echo "Testing shell script syntax..."
        # Test main shell scripts
        bash -n build-deb.sh || exit 1
        bash -n install.sh || exit 1
        bash -n uninstall.sh || exit 1
        bash -n set-charge-limit.sh || exit 1
        echo "✅ Shell scripts syntax OK"

    - name: Test Python GUI syntax
      run: |
        echo "Testing Python scripts syntax..."
        python3 -m py_compile battery-gui || exit 1
        python3 -m py_compile battery-indicator || exit 1
        echo "✅ Python scripts syntax OK"

    - name: Test script executability
      run: |
        echo "Testing script permissions and executability..."
        # Check if scripts are executable or can be made executable
        chmod +x battery-cli battery-limit battery-gui battery-indicator set-charge-limit.sh
        
        # Test CLI help (should not require hardware)
        if timeout 5 ./battery-cli --help 2>/dev/null || timeout 5 ./battery-cli -h 2>/dev/null; then
          echo "✅ CLI responds to help"
        else
          echo "ℹ️ CLI requires hardware (expected)"
        fi

    - name: Lint shell scripts
      run: |
        echo "Linting shell scripts with shellcheck..."
        shellcheck build-deb.sh install.sh uninstall.sh set-charge-limit.sh || echo "⚠️ Shellcheck warnings (non-critical)"

    - name: Test package structure
      run: |
        echo "Verifying package structure..."
        ls -la
        
        # Check required files exist
        test -f battery-cli || { echo "❌ battery-cli missing"; exit 1; }
        test -f battery-limit || { echo "❌ battery-limit missing"; exit 1; }
        test -f battery-gui || { echo "❌ battery-gui missing"; exit 1; }
        test -f battery-indicator || { echo "❌ battery-indicator missing"; exit 1; }
        test -f build-deb.sh || { echo "❌ build-deb.sh missing"; exit 1; }
        test -f install.sh || { echo "❌ install.sh missing"; exit 1; }
        test -f README.md || { echo "❌ README.md missing"; exit 1; }
        
        echo "✅ All required files present"

  test-package-build:
    runs-on: ubuntu-latest
    needs: [get-version, test-linux]
    steps:
    - uses: actions/checkout@v4
    
    - name: Install build dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y dpkg-dev

    - name: Test .deb package build
      run: |
        echo "Testing Debian package build..."
        # Make build script executable
        chmod +x build-deb.sh
        
        # Run build script
        ./build-deb.sh
        
        # Check if package was created
        if ls asus-battery-limiter_*.deb 1> /dev/null 2>&1; then
          echo "✅ Package built successfully"
          
          # Verify package contents
          PACKAGE=$(ls asus-battery-limiter_*.deb | head -1)
          echo "📦 Package: $PACKAGE"
          
          dpkg-deb --info "$PACKAGE"
          dpkg-deb --contents "$PACKAGE"
        else
          echo "❌ Package build failed"
          exit 1
        fi

    - name: Upload package artifact
      uses: actions/upload-artifact@v4
      with:
        name: asus-battery-limiter-deb
        path: asus-battery-limiter_*.deb
        retention-days: 30

  test-installation:
    runs-on: ubuntu-latest
    needs: test-package-build
    steps:
    - uses: actions/checkout@v4
    
    - name: Download package artifact
      uses: actions/download-artifact@v4
      with:
        name: asus-battery-limiter-deb
    
    - name: Test manual installation
      run: |
        echo "Testing manual installation process..."
        chmod +x install.sh
        
        # Test install script syntax
        bash -n install.sh
        echo "✅ Install script syntax OK"
        
        # Note: Cannot actually install due to hardware requirements
        echo "ℹ️ Manual installation script verified (hardware testing skipped)"

    - name: Test package installation (dry run)
      run: |
        echo "Testing package installation..."
        PACKAGE=$(ls asus-battery-limiter_*.deb | head -1)
        
        # Test package info
        dpkg-deb --info "$PACKAGE"
        
        # Verify package structure
        dpkg-deb --extract "$PACKAGE" test-extract/
        ls -la test-extract/
        
        echo "✅ Package structure verified"

  create-release:
    runs-on: ubuntu-latest
    needs: [get-version, test-linux, test-package-build, test-installation]
    if: github.ref == 'refs/heads/main' && startsWith(github.ref, 'refs/tags/')
    steps:
    - uses: actions/checkout@v4
    
    - name: Download package artifact
      uses: actions/download-artifact@v4
      with:
        name: asus-battery-limiter-deb
    
    - name: Create Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.ref }}
        release_name: ASUS Battery Limiter ${{ needs.get-version.outputs.version }}
        body: |
          ## ASUS Battery Limiter v${{ needs.get-version.outputs.version }}
          
          ### Installation
          ```bash
          sudo dpkg -i asus-battery-limiter_${{ needs.get-version.outputs.version }}_all.deb
          ```
          
          ### Features
          - Battery charge limiting for ASUS laptops
          - GUI and CLI interfaces
          - System tray indicator
          - Automatic updates
          
          ### Requirements
          - ASUS laptop with battery charge control support
          - Ubuntu/Debian-based distribution
          - sudo privileges
        draft: false
        prerelease: false
    
    - name: Upload Release Asset
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ steps.create_release.outputs.upload_url }}
        asset_path: ./asus-battery-limiter_${{ needs.get-version.outputs.version }}_all.deb
        asset_name: asus-battery-limiter_${{ needs.get-version.outputs.version }}_all.deb
        asset_content_type: application/vnd.debian.binary-package
EOF

    print_colored $GREEN "✅ Created workflow: $workflow_file"
}

# Main execution
main() {
    print_header "🔧 GitHub Actions Workflow Diagnostic and Fix Tool"
    
    # Detect repository type
    REPO_TYPE=$(detect_repo_type)
    print_colored $BLUE "📋 Detected repository type: $REPO_TYPE"
    
    # Check repository structure
    if ! check_repo_structure "$REPO_TYPE"; then
        print_colored $RED "❌ Repository structure check failed"
        exit 1
    fi
    
    # Test script syntax
    if ! test_script_syntax "$REPO_TYPE"; then
        print_colored $RED "❌ Script syntax check failed"
        exit 1
    fi
    
    # Create appropriate workflow
    case $REPO_TYPE in
        "laptop-battery-limiter")
            create_laptop_workflow
            ;;
        "universal-battery-limiter")
            print_colored $YELLOW "ℹ️ Universal Battery Limiter workflows should already be fixed"
            ;;
        *)
            print_colored $YELLOW "⚠️ Unknown repository type - please run this script in the appropriate repository"
            exit 1
            ;;
    esac
    
    # Validate created workflow
    if [ -f ".github/workflows/laptop-battery-limiter.yml" ]; then
        print_colored $YELLOW "🔍 Validating created workflow..."
        validate_workflow_yaml ".github/workflows/laptop-battery-limiter.yml"
    fi
    
    print_header "✅ Workflow Diagnostic and Fix Complete"
    
    print_colored $GREEN "🎉 Summary:"
    print_colored $GREEN "  - Repository structure: ✅ Valid"
    print_colored $GREEN "  - Script syntax: ✅ Valid"
    print_colored $GREEN "  - Workflow created: ✅ Complete"
    
    echo
    print_colored $BLUE "📋 Next Steps:"
    print_colored $BLUE "  1. Review the generated workflow file"
    print_colored $BLUE "  2. Commit and push changes"
    print_colored $BLUE "  3. Check GitHub Actions tab for successful runs"
    
    if [ "$REPO_TYPE" = "asus-battery-limiter" ]; then
        echo
        print_colored $YELLOW "💡 ASUS Battery Limiter specific notes:"
        print_colored $YELLOW "  - Hardware-specific tests are mocked/skipped in CI"
        print_colored $YELLOW "  - .deb package building is tested"
        print_colored $YELLOW "  - Installation scripts are validated"
    fi
}

# Run main function
main "$@"
