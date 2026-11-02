#!/bin/bash
# Name: auto_update_phpmyadmin.sh
# Description: this script searches for the latest phpMyAdmin version and updates if necessary.
# Author: Thom Pol
# Tested on systems that were installed according to HowToForge's Perfect Server guides for auto/manual install (Debian 10+)

# To install the script, run:
# curl https://git.ispconfig.org/ispconfig/tools/-/raw/master/auto_update_phpmyadmin.sh -L -o /etc/cron.daily/auto_update_phpmyadmin && chmod +x /etc/cron.daily/auto_update_phpmyadmin
# To update the script, run:
# [ -f /etc/cron.daily/auto_update_phpmyadmin ] && curl 'https://git.ispconfig.org/ispconfig/tools/-/raw/master/auto_update_phpmyadmin.sh' -L -o /etc/cron.daily/auto_update_phpmyadmin && chmod +x /etc/cron.daily/auto_update_phpmyadmin

# User variables
# Directory where phpMyAdmin is installed
phpMyAdminDir="/usr/share/phpmyadmin"
# Enable logging to a file (set to empty string to disable)
logFile="/var/log/auto_update_phpmyadmin.log"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Centralized logging function
# Parameters: $1 = log level (INFO, WARN, ERROR), $2 = message
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local output="[${timestamp}] [${level}] ${message}"
    
    # Always output to CLI
    echo "${output}"
    
    # Log to file if configured and writable
    if [ -n "$logFile" ] && [ -w "$(dirname "$logFile")" ]; then
        # Log rotation: archive monthly and remove logs older than a month
        logDir="$(dirname "$logFile")"
        logBase="$(basename "$logFile")"
        monthSuffix="$(date '+%Y-%m')"
        archiveFile="$logDir/${logBase}.${monthSuffix}"
        # If it's a new month and logFile exists, rotate
        if [ -f "$logFile" ]; then
            lastLogMonth=$(date -r "$logFile" '+%Y-%m')
            if [ "$lastLogMonth" != "$monthSuffix" ]; then
                mv "$logFile" "$archiveFile"
            fi
        fi
    # Remove old logs (older than ~100 days)
    find "$logDir" -maxdepth 1 -name "${logBase}.*" -type f -mtime +100 -exec rm -f {} \;
        echo "${output}" >> "$logFile"
    fi
}

# Validate version format (e.g., 5.2.3)
is_valid_version() {
    local version="$1"
    if [[ $version =~ ^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    return 1
}

# Validate URL format
is_valid_url() {
    local url="$1"
    if [[ $url =~ ^https?:\/\/[-a-zA-Z0-9@:%._+~#=]+\.[-a-zA-Z0-9]{2,}([-a-zA-Z0-9@:%_+.~#?&/=])*$ ]]; then
        return 0
    fi
    return 1
}

# Extract version and URL from JSON endpoint
# Always uses the newest release (compares version with releases[].version)
fetch_latest_version() {
    local jsonUrl="https://www.phpmyadmin.net/home_page/version.json"
    local jsonResponse
    
    log_message "INFO" "Fetching latest phpMyAdmin version from JSON endpoint..."
    jsonResponse=$(curl -s -w "\n%{http_code}" "$jsonUrl")
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to fetch version information from $jsonUrl"
        return 1
    fi
    
    # Extract HTTP status code (last line)
    local httpCode=$(echo "$jsonResponse" | tail -n1)
    local jsonBody=$(echo "$jsonResponse" | sed '$d')
    
    if [ "$httpCode" != "200" ]; then
        log_message "ERROR" "Failed to fetch version JSON: HTTP $httpCode"
        return 1
    fi
    
    # Check if jq is available, otherwise use grep
    if command -v jq &> /dev/null; then
        local mainVersion=$(echo "$jsonBody" | jq -r '.version' 2>/dev/null)
        local firstReleaseVersion=$(echo "$jsonBody" | jq -r '.releases[0].version' 2>/dev/null)
        
        # Use the latest version (compare main version with first release version)
        # The main "version" field should be the latest, but we validate against releases
        local version="$mainVersion"
        if [ -z "$version" ] || [ "$version" == "null" ]; then
            version="$firstReleaseVersion"
        fi
    else
        # Fallback to grep/sed parsing
        local version=$(echo "$jsonBody" | grep -oP '"version"\s*:\s*"\K[^"]+' | head -1)
    fi
    
    # Validate the extracted version
    if ! is_valid_version "$version"; then
        log_message "ERROR" "Invalid version format: $version"
        return 1
    fi
    
    # Construct download URL
    local url="https://files.phpmyadmin.net/phpMyAdmin/${version}/phpMyAdmin-${version}-all-languages.zip"
    
    # Validate the constructed URL
    if ! is_valid_url "$url"; then
        log_message "ERROR" "Invalid download URL: $url"
        return 1
    fi
    
    # Set global variables directly
    latestVersion="$version"
    latestUrl="$url"
    
    return 0
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Static variables
currentVersion=$(grep -m 1 "version" /usr/share/phpmyadmin/package.json 2>/dev/null | grep -oEm 1 "[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}")

# Initialize latest version variables
latestVersion=""
latestUrl=""

# Fetch latest version and URL
fetch_latest_version
if [ $? -ne 0 ]; then
    log_message "ERROR" "Failed to retrieve latest version information. Exiting."
    exit 1
fi

# Validate current version
if ! is_valid_version "$currentVersion"; then
    log_message "ERROR" "Could not determine current phpMyAdmin version from package.json"
    exit 1
fi

log_message "INFO" "Current version: $currentVersion, Latest version: $latestVersion"

# Update this script automatically (optional, not enabled by default for security reasons)
# curl -s https://git.ispconfig.org/ispconfig/tools/-/raw/master/auto_update_phpmyadmin.sh -L -o /etc/cron.daily/auto_update_phpmyadmin
# chmod +x /etc/cron.daily/auto_update_phpmyadmin

# Check TempDir permissions
if id -u ispapps >/dev/null 2>&1; then
    chown -R ispapps:www-data /var/lib/phpmyadmin
fi

# Check if phpMyAdmin is installed via apt (not supported by this script)
if [ $(dpkg --list phpmyadmin 2>/dev/null | grep '^i' | wc -l) == "1" ]; then
    log_message "WARN" "phpMyAdmin is installed through apt. Run apt update && apt upgrade to update to the latest available package."
    exit 0
fi

# Check if phpMyAdmin directory exists
if [ ! -d "$phpMyAdminDir" ]; then
    log_message "ERROR" "phpMyAdmin directory not found: $phpMyAdminDir"
    exit 1
fi

# Main update logic
if [ "$currentVersion" != "$latestVersion" ] && [ "$currentVersion" != "" ] && [ "$latestVersion" != "" ]; then
    currentDate=$(date +"%y%m%d%H%M%S")
    phpMyAdminBakDir=""$phpMyAdminDir"-bak-"$currentVersion"-"$currentDate""
    log_message "INFO" "phpMyAdmin version is out of date. Current: $currentVersion, Latest: $latestVersion"
    log_message "INFO" "Starting phpMyAdmin update."
    
    # Download newest version
    log_message "INFO" "Downloading phpMyAdmin $latestVersion from $latestUrl"
    curl "$latestUrl" -s -L -o /tmp/phpMyAdmin-"$latestVersion"-all-languages.zip
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to download phpMyAdmin from $latestUrl"
        exit 1
    fi
    
    # Verify the downloaded file exists
    if [ ! -f /tmp/phpMyAdmin-"$latestVersion"-all-languages.zip ]; then
        log_message "ERROR" "Downloaded file not found: /tmp/phpMyAdmin-$latestVersion-all-languages.zip"
        exit 1
    fi
    
    # Unzip the file
    log_message "INFO" "Extracting phpMyAdmin archive..."
    unzip -q /tmp/phpMyAdmin-"$latestVersion"-all-languages.zip -d /tmp
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to extract phpMyAdmin archive"
        exit 1
    fi
    
    if [ -d /tmp/phpMyAdmin-"$latestVersion"-all-languages ]; then
        # Move current install to backup directory
        log_message "INFO" "Backing up current installation to $phpMyAdminBakDir"
        mv "$phpMyAdminDir" "$phpMyAdminBakDir"
        
        if [ $? -ne 0 ]; then
            log_message "ERROR" "Failed to backup current phpMyAdmin installation"
            exit 1
        fi
        
        # Move new release to the phpMyAdmin directory
        log_message "INFO" "Installing new phpMyAdmin version..."
        mv /tmp/phpMyAdmin-"$latestVersion"-all-languages "$phpMyAdminDir"
        
        if [ $? -ne 0 ]; then
            log_message "ERROR" "Failed to move new installation to $phpMyAdminDir. Attempting rollback..."
            if [ -d "$phpMyAdminBakDir" ]; then
                mv "$phpMyAdminBakDir" "$phpMyAdminDir"
                log_message "ERROR" "Rollback completed. Installation remains at version $currentVersion"
            fi
            exit 1
        fi
        
        # Copy old config files to the new installation
        log_message "INFO" "Restoring configuration files..."
        if [ -f "$phpMyAdminBakDir"/config.inc.php ]; then
            cp "$phpMyAdminBakDir"/config.inc.php "$phpMyAdminDir"/
            if [ $? -ne 0 ]; then
                log_message "WARN" "Failed to copy config.inc.php"
            fi
        fi
        
        if [ -f "$phpMyAdminBakDir"/.htaccess ]; then
            log_message "INFO" ".htaccess file found. Copying to new installation."
            cp "$phpMyAdminBakDir"/.htaccess "$phpMyAdminDir"/
            if [ $? -ne 0 ]; then
                log_message "WARN" "Failed to copy .htaccess file"
            fi
        fi
        
        # Clean up temporary files
        rm -f /tmp/phpMyAdmin-"$latestVersion"-all-languages.zip
        
        # Wait a moment
        sleep 1
        
        # Announce that we're done
        log_message "INFO" "phpMyAdmin has been updated to version $latestVersion."
        log_message "INFO" "If you had any custom config files other than config.inc.php and/or .htaccess, you have to copy them manually from $phpMyAdminBakDir/ to $phpMyAdminDir/"
    else
        log_message "ERROR" "Could not extract phpMyAdmin archive. Directory not found: /tmp/phpMyAdmin-$latestVersion-all-languages"
        exit 1
    fi
    
elif [ "$currentVersion" == "$latestVersion" ]; then
    # Local install is up-to-date
    log_message "INFO" "phpMyAdmin is already up-to-date (version $currentVersion)"
else
    log_message "ERROR" "Unknown error or invalid version information. Current: $currentVersion, Latest: $latestVersion"
    exit 1
fi
