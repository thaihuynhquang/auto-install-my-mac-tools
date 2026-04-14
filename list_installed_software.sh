#!/bin/bash

# Script to list installed software on macOS and output as markdown
OUTPUT_FILE="installed_software.md"
BREW_ENV_PREFIX="HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_FROM_API=1"

# Create markdown file with header
cat > "$OUTPUT_FILE" << EOL
# Installed Software on My MacBook

*Generated on $(date "+%Y-%m-%d %H:%M:%S")*

This document lists all software installed on this MacBook.

EOL

# Function to get software description
get_description() {
    local software=$1
    local type=$2
    
    # Try to get description from predefined list first
    local predefined_desc=""
    case "$type" in
        "brew")
            case "$software" in
                "node") predefined_desc="JavaScript runtime environment. Latest LTS: 20.11.1 (Iron)" ;;
                "node@16") predefined_desc="JavaScript runtime environment. LTS ended 2023-09-11" ;;
                "python@3.11") predefined_desc="Interpreted programming language. Latest: 3.11.8" ;;
                "python@3.12") predefined_desc="Interpreted programming language. Latest: 3.12.3" ;;
                "python@3.13") predefined_desc="Interpreted programming language. Latest: 3.13.0 (Alpha)" ;;
                "redis") predefined_desc="In-memory database that persists on disk. Latest: 7.2.4" ;;
                "mongodb-community") predefined_desc="Document-oriented database. Latest: 7.0.5" ;;
                "yarn") predefined_desc="JavaScript package manager. Latest: 1.22.22" ;;
                "wget") predefined_desc="Internet file retriever. Latest: 1.24.5" ;;
                "openssl@3") predefined_desc="Cryptography and SSL/TLS toolkit. Latest: 3.2.1" ;;
            esac
            ;;
        # Other cases remain unchanged
    esac
    
    # If we have a predefined description, use it
    if [ -n "$predefined_desc" ]; then
        echo "$predefined_desc"
        return
    fi
    
    # Fall back to the original switch case for other types
    case "$type" in
        "cask")
            case "$software" in
                "font-fira-code") echo "Monospaced font with programming ligatures" ;;
                "react-native-debugger") echo "Standalone debugger for React Native applications" ;;
                "reactotron") echo "Desktop app for inspecting React JS and React Native projects" ;;
                "zulu@11") echo "OpenJDK distribution from Azul. LTS until 2024-10" ;;
                "zulu@17") echo "OpenJDK distribution from Azul. LTS until 2029-10" ;;
                *) echo "No description available" ;;
            esac
            ;;
        "ruby")
            case "$software" in
                "ruby-2.7.6") echo "Dynamic programming language. EOL: 2023-03-31" ;;
                "ruby-2.7.8") echo "Dynamic programming language. EOL: 2023-03-31" ;;
                "ruby-3.2.4") echo "Dynamic programming language. Maintenance until 2026-03-31" ;;
                "ruby-3.3.6") echo "Dynamic programming language. Latest: 3.3.0" ;;
                *) echo "Ruby programming language version" ;;
            esac
            ;;
        "node")
            case "$software" in
                "v16.20.2") echo "Node.js Gallium. LTS ended 2023-09-11" ;;
                "v18.20.6") echo "Node.js Hydrogen. LTS ended 2025-04-30" ;;
                "v20.18.2") echo "Node.js Iron. LTS until 2026-04-30" ;;
                "v22.13.1") echo "Node.js. Current version, not LTS" ;;
                *) echo "Node.js JavaScript runtime" ;;
            esac
            ;;
        *)
            echo "No description available"
            ;;
    esac
}

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    echo "## Homebrew Packages (CLI Tools)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    formula_versions=$(env $BREW_ENV_PREFIX brew list --formula --versions 2>/dev/null)

    # Get Homebrew formula packages and format as markdown list
    env $BREW_ENV_PREFIX brew list --formula 2>/dev/null | sort | while read -r package; do
        version=$(echo "$formula_versions" | awk -v pkg="$package" '$1 == pkg {print $2; exit}')
        version=${version:-Unknown}
        description=$(get_description "$package" "brew")
        echo "- \`$package\` - version $version" >> "$OUTPUT_FILE"
        echo "  - *$description*" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
    
    echo "## Homebrew Cask Applications" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get Homebrew cask applications and format as markdown list
    cask_versions=$(env $BREW_ENV_PREFIX brew list --cask --versions 2>/dev/null)
    env $BREW_ENV_PREFIX brew list --cask 2>/dev/null | sort | while read -r app; do
        version=$(echo "$cask_versions" | awk -v pkg="$app" '$1 == pkg {print $2; exit}')
        version=${version:-Unknown}
        description=$(get_description "$app" "cask")
        echo "- **$app** - version $version" >> "$OUTPUT_FILE"
        echo "  - *$description*" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
else
    echo "## Homebrew" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Homebrew is not installed." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Check if RVM is installed
if command -v rvm &> /dev/null; then
    echo "## Ruby Version Manager (RVM)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get RVM version
    rvm_version=$(rvm --version | head -n 1 | awk '{print $2}')
    echo "RVM version: $rvm_version" >> "$OUTPUT_FILE"
    echo "  - *Ruby environment manager to install and manage multiple Ruby versions*" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # List installed Ruby versions
    echo "### Installed Ruby Versions" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    rvm list | grep -v "^$" | grep -v "=>" | grep "ruby" | sed 's/^[ \t]*//' | while read -r ruby_version; do
        ruby_short_version=$(echo "$ruby_version" | grep -o "ruby-[0-9]\.[0-9]\.[0-9]")
        description=$(get_description "$ruby_short_version" "ruby")
        echo "- $ruby_version" >> "$OUTPUT_FILE"
        echo "  - *$description*" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
    
    # Show default Ruby version
    default_ruby=$(rvm list | grep "=>" | sed 's/^.*=> //' | sed 's/ .*$//')
    if [ -n "$default_ruby" ]; then
        echo "Default Ruby: $default_ruby" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
else
    echo "## Ruby Version Manager (RVM)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "RVM is not installed." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Check if NVM is installed
if [ -d "$HOME/.nvm" ] || command -v nvm &> /dev/null; then
    echo "## Node Version Manager (NVM)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Source NVM if it exists but isn't in PATH
    if [ -d "$HOME/.nvm" ] && ! command -v nvm &> /dev/null; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Get NVM version if available
    if command -v nvm &> /dev/null; then
        nvm_version=$(nvm --version 2>/dev/null)
        echo "NVM version: $nvm_version" >> "$OUTPUT_FILE"
        echo "  - *Node.js version manager to install and switch between multiple Node.js versions*" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # List installed Node.js versions
        echo "### Installed Node.js Versions" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        nvm ls --no-colors | grep -v "default" | grep -v "node ->" | grep -v "iojs ->" | grep -v "N/A" | grep "v" | sed 's/^[ \t]*//' | while read -r node_version; do
            node_short_version=$(echo "$node_version" | grep -o "v[0-9]*\.[0-9]*\.[0-9]*")
            description=$(get_description "$node_short_version" "node")
            echo "- $node_version" >> "$OUTPUT_FILE"
            echo "  - *$description*" >> "$OUTPUT_FILE"
        done
        echo "" >> "$OUTPUT_FILE"
        
        # Show current Node.js version
        current_node=$(nvm current 2>/dev/null)
        if [ -n "$current_node" ]; then
            echo "Current Node.js: $current_node" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
    else
        echo "NVM is installed but not properly configured in the current shell." >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
else
    echo "## Node Version Manager (NVM)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "NVM is not installed." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Check if npm is installed
echo "## npm Global Packages" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
if command -v npm &> /dev/null; then
    npm_global_json=$(npm list -g --depth=0 --json 2>/dev/null)
    npm_packages=$(echo "$npm_global_json" | jq -r '.dependencies // {} | to_entries[] | "\(.key)\t\(.value.version // "Unknown")"' | sort)

    if [ -n "$npm_packages" ]; then
        while IFS=$'\t' read -r package version; do
            echo "- \`$package\` - version $version" >> "$OUTPUT_FILE"
        done <<< "$npm_packages"
    else
        echo "No global npm packages found." >> "$OUTPUT_FILE"
    fi
else
    echo "npm is not installed or not available in PATH." >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# List applications in /Applications
echo "## Applications in /Applications" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
find /Applications -maxdepth 1 -name "*.app" | sort | sed 's/\/Applications\///' | while read -r app; do
    # Extract version if possible
    version_file="/Applications/$app/Contents/Info.plist"
    if [ -f "$version_file" ]; then
        version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$version_file" 2>/dev/null || echo "Unknown")
        echo "- **${app%.app}** - version $version" >> "$OUTPUT_FILE"
    else
        echo "- **${app%.app}**" >> "$OUTPUT_FILE"
    fi
done
echo "" >> "$OUTPUT_FILE"

# List applications in ~/Applications if it exists
if [ -d ~/Applications ]; then
    echo "## Applications in ~/Applications" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    find ~/Applications -maxdepth 1 -name "*.app" | sort | sed 's/.*\/Applications\///' | while read -r app; do
        # Extract version if possible
        version_file=~/Applications/"$app/Contents/Info.plist"
        if [ -f "$version_file" ]; then
            version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$version_file" 2>/dev/null || echo "Unknown")
            echo "- **${app%.app}** - version $version" >> "$OUTPUT_FILE"
        else
            echo "- **${app%.app}**" >> "$OUTPUT_FILE"
        fi
    done
    echo "" >> "$OUTPUT_FILE"
else
    echo "## Applications in ~/Applications" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "No ~/Applications folder found." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

echo "Software listing complete! Markdown file created: $OUTPUT_FILE"
