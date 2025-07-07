# Publishing Guide - ASUS Battery Limiter

This guide explains how to publish ASUS Battery Limiter for distribution, including Ubuntu native updater integration for automatic updates.

## Overview

The project supports multiple distribution channels:
- **Direct .deb packages** (GitHub Releases)
- **Ubuntu PPA** (Personal Package Archives) - Native Ubuntu updates
- **Snap Store** - Universal Linux packages with automatic updates
- **Custom APT Repository** - Self-hosted package repository

## Ubuntu Native Updater Integration

For the best user experience, we recommend setting up at least one native Ubuntu updater method (PPA or Snap Store). This allows users to receive updates through Ubuntu's built-in update system.

### Quick Setup

Run the automated setup script:

```bash
chmod +x setup-ubuntu-updater.sh
./setup-ubuntu-updater.sh
```

This script will:
- Install required dependencies
- Generate GPG keys for package signing
- Create configuration templates for PPA, Snap, and APT repository
- Set up GitHub Actions integration
- Generate user installation guides

## Method 1: Ubuntu PPA (Recommended)

PPAs integrate seamlessly with Ubuntu's Software Updater and `apt` command.

### Prerequisites

1. **Launchpad Account**: Create account at https://launchpad.net
2. **GPG Key**: For signing packages
3. **PPA Repository**: Create PPA on Launchpad

### Setup Steps

1. **Create Launchpad PPA**:
   ```bash
   # Go to https://launchpad.net/~yourusername/+activate-ppa
   # Create PPA named "battery-limiter"
   ```

2. **Generate and Upload GPG Key**:
   ```bash
   # Generate GPG key (if not exists)
   gpg --full-generate-key
   
   # Get key ID
   gpg --list-secret-keys --keyid-format=long
   
   # Upload to Launchpad
   gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
   ```

3. **Configure GitHub Secrets**:
   ```
   PPA_GPG_PRIVATE_KEY: [Base64 encoded private key]
   PPA_GPG_PASSPHRASE: [Your GPG passphrase]
   PPA_GPG_KEY_ID: [Your GPG key ID]
   PPA_USER: [Your Launchpad username]
   PPA_NAME: [Your PPA name, e.g., 'battery-limiter']
   ```

4. **Enable PPA in GitHub**:
   ```
   # Set repository variable
   ENABLE_PPA: true
   ```

### User Installation (PPA)

Users can install via:

```bash
sudo add-apt-repository ppa:yourusername/battery-limiter
sudo apt update
sudo apt install asus-battery-limiter
```

Updates will appear in Software Updater automatically.

## Method 2: Snap Store

Snap packages work across all Linux distributions with automatic updates.

### Prerequisites

1. **Ubuntu One Account**: For Snap Store
2. **Snapcraft**: Package building tool
3. **Store Registration**: Register app name

### Setup Steps

1. **Install Snapcraft**:
   ```bash
   sudo snap install snapcraft --classic
   ```

2. **Register Snap Name**:
   ```bash
   snapcraft register asus-battery-limiter
   ```

3. **Generate Store Token**:
   ```bash
   snapcraft export-login token.txt
   # Upload token.txt content to GitHub secrets
   ```

4. **Configure GitHub Secrets**:
   ```
   SNAPCRAFT_TOKEN: [Content of token.txt]
   ```

5. **Enable Snap in GitHub**:
   ```
   # Set repository variable
   ENABLE_SNAP: true
   ```

### User Installation (Snap)

Users can install via:

```bash
sudo snap install asus-battery-limiter
```

Or through the Ubuntu Software app.

## Method 3: Custom APT Repository

Host your own APT repository for full control.

### Prerequisites

1. **Web Server**: To host repository files
2. **Domain Name**: For repository URL
3. **GPG Key**: For package signing

### Setup Steps

1. **Prepare Repository Structure**:
   ```bash
   mkdir -p apt-repository/{conf,dists,pool}
   ```

2. **Configure Repository**:
   ```bash
   # Edit apt-repository/conf/distributions
   Codename: jammy
   Components: main
   Architectures: all amd64
   SignWith: YOUR_GPG_KEY_ID
   ```

3. **Configure GitHub Secrets**:
   ```
   APT_REPO_GPG_KEY: [Base64 encoded private key]
   APT_REPO_GPG_PASSPHRASE: [Your GPG passphrase]
   APT_REPO_GPG_KEY_ID: [Your GPG key ID]
   ```

4. **Enable APT Repository in GitHub**:
   ```
   # Set repository variable
   ENABLE_APT_REPO: true
   ```

### User Installation (Custom APT)

Users can install via:

```bash
wget -qO - https://yourdomain.com/public-key.asc | sudo apt-key add -
echo "deb https://yourdomain.com/apt-repository/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/asus-battery-limiter.list
sudo apt update
sudo apt install asus-battery-limiter
```

## Method 4: Direct .deb Packages

For users who prefer manual installation.

### Setup

This is already configured in the main CI/CD workflow. Every GitHub release automatically builds and uploads a .deb package.

### User Installation (Direct)

Users can install via:

```bash
wget https://github.com/yourusername/Battery-Limter/releases/latest/download/asus-battery-limiter_VERSION_all.deb
sudo dpkg -i asus-battery-limiter_*.deb
sudo apt-get install -f  # Install dependencies
```

## GitHub Actions Workflow

The project includes two GitHub Actions workflows:

### 1. Main Build Workflow (`.github/workflows/python-app.yml`)
- Builds and tests on every push
- Creates .deb packages for releases
- Supports manual version releases

### 2. Ubuntu Updater Workflow (`.github/workflows/ubuntu-updater.yml`)
- Publishes to PPA, Snap Store, and custom APT repository
- Runs on GitHub releases or manual dispatch
- Requires appropriate secrets and variables to be configured

## Version Management

Use the version update script to maintain consistency:

```bash
# Update to new version
./update-version.sh 1.1.0

# This updates:
# - debian-package/DEBIAN/control
# - All script files
# - snapcraft.yaml
# - Documentation
```

## Release Process

1. **Update Version**:
   ```bash
   ./update-version.sh X.Y.Z
   ```

2. **Commit Changes**:
   ```bash
   git add .
   git commit -m "Release version X.Y.Z"
   git push
   ```

3. **Create GitHub Release**:
   - Go to GitHub Releases
   - Create new release with tag `vX.Y.Z`
   - Add release notes

4. **Automated Publishing**:
   - GitHub Actions will automatically:
     - Build .deb package
     - Publish to configured channels (PPA, Snap, APT)
     - Update package repositories

## Monitoring and Maintenance

### Update Checking

The application includes built-in update checking that:
1. First checks native package managers (apt, snap)
2. Falls back to GitHub API for manual installations
3. Guides users to appropriate update methods

### Repository Maintenance

- **PPA**: Launchpad automatically builds for supported Ubuntu versions
- **Snap Store**: Automatic updates pushed to users
- **Custom APT**: Requires server maintenance for hosting

## User Experience

With native updater integration:

1. **Installation**: Users can install via familiar package managers
2. **Updates**: Automatic through Software Updater or snap refresh
3. **Uninstallation**: Standard `apt remove` or `snap remove`
4. **Dependencies**: Automatically handled by package managers

## Troubleshooting

### Common Issues

1. **GPG Key Errors**: Ensure keys are properly uploaded to Launchpad/keyservers
2. **Build Failures**: Check GitHub Actions logs for detailed error messages
3. **PPA Delays**: Launchpad builds can take time, especially for new packages
4. **Snap Review**: First-time snaps require manual review by Snap Store team

### Debug Commands

```bash
# Test .deb package
dpkg-deb -I package.deb
dpkg-deb -c package.deb

# Test PPA upload
dput ppa:user/ppa package_source.changes

# Test snap build
snapcraft --debug

# Check GPG setup
gpg --list-secret-keys
```

## Security Considerations

- **GPG Keys**: Store private keys securely, use strong passphrases
- **GitHub Secrets**: Never commit secrets to repository
- **Package Signing**: Always sign packages for user security
- **Repository Security**: Use HTTPS for all repository access

## Best Practices

1. **Version Consistency**: Use semantic versioning (X.Y.Z)
2. **Release Notes**: Always include meaningful release notes
3. **Testing**: Test packages before publishing
4. **Documentation**: Keep installation guides up to date
5. **User Communication**: Notify users of breaking changes

## Future Enhancements

- **Debian Official Repository**: Submit to Debian for wider distribution
- **Flatpak Support**: Add Flatpak packaging for additional distribution
- **Automatic Changelog**: Generate changelogs from git commits
- **Multi-Distro Support**: Add support for Fedora, openSUSE, etc.

## Support

For questions about publishing:
- GitHub Issues: Repository issue tracker
- Launchpad Support: https://help.launchpad.net/
- Snapcraft Documentation: https://snapcraft.io/docs

---

**Note**: Replace placeholder usernames, domains, and repository URLs with your actual details before using these instructions.
