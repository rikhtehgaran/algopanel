#!/usr/bin/env sh

# Ensure correct default permissions for created files and directories
umask 0022

CURDIR=$(pwd) ;
BASEDIR=$(dirname $0) ;
BASEDIR=$(realpath ${BASEDIR}) ;

CURL=$(which curl) ;
WGET=$(which wget) ;
PHP=$(which php) ;
APT=$(which apt-get) ;

use_git=false;
if [ -d .git ]; then
  use_git=true;
fi

if [ "$APT" = "" ] ; then
	echo "It seems you are using a distribution that has no apt-get available. This is not supported.";
	exit 1 ;
fi

# ==============================================================================
# Configuration & Mirrors Setup
# ==============================================================================
ALGOPANEL_HOST="${ALGOPANEL_HOST:-https://get.algopanel.ir}"
AI_PACKAGE_URL="${ALGOPANEL_HOST}/downloads/algopanel-ai.tar.gz"

configure_mirrors() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		OS_ID=$ID
		OS_CODENAME=$VERSION_CODENAME
	else
		OS_ID=""
		OS_CODENAME=""
	fi

	# Configure Iranian/custom mirrors for Ubuntu if needed
	# ENABLE_LOCAL_MIRRORS can be set to 1 or default auto-detection
	ENABLE_LOCAL_MIRRORS="${ENABLE_LOCAL_MIRRORS:-1}"

	if [ "$ENABLE_LOCAL_MIRRORS" = "1" ] && [ "$OS_ID" = "ubuntu" ]; then
		echo "Configuring ArvanCloud Ubuntu mirror for ${OS_CODENAME}..."
		
		# Backup original sources if not already backed up
		if [ ! -f /etc/apt/sources.list.bak_algopanel ] && [ -f /etc/apt/sources.list ]; then
			cp /etc/apt/sources.list /etc/apt/sources.list.bak_algopanel
		fi

		# Ubuntu 24.04 (noble) and newer also use /etc/apt/sources.list.d/ubuntu.sources
		if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
			if [ ! -f /etc/apt/sources.list.d/ubuntu.sources.bak_algopanel ]; then
				cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak_algopanel
			fi
			# Temporarily disable deb822 ubuntu.sources so sources.list takes precedence
			mv /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.disabled_algopanel 2>/dev/null || true
		fi

		cat << EOF > /etc/apt/sources.list
deb http://mirror.arvancloud.ir/ubuntu ${OS_CODENAME} main restricted universe multiverse
deb http://mirror.arvancloud.ir/ubuntu ${OS_CODENAME}-updates main restricted universe multiverse
deb http://mirror.arvancloud.ir/ubuntu ${OS_CODENAME}-backports main restricted universe multiverse
deb http://mirror.arvancloud.ir/ubuntu ${OS_CODENAME}-security main restricted universe multiverse
EOF
	fi
}

# Run mirror setup before calling apt-get
configure_mirrors

# ==============================================================================
# Dependency Checking
# ==============================================================================
if [ "$CURL" = "" ] ; then
	if [ "$WGET" = "" ] ; then
		echo "Curl and Wget missing, trying to install." ;
		apt-get update -qq && apt-get -y -qq install wget;
		WGET=$(which wget) ;
	fi
	if [ "$WGET" = "" ] ; then
		echo "Wget and curl are missing. Please install either wget or curl package." ;
		exit 1 ;
	fi
fi

if [ "$PHP" = "" ] ; then
	echo "PHP cli missing, trying to install." ;
	apt-get update -qq && apt-get  -y -qq install dialog && apt-get -y -qq install php-cli && apt-get -y -qq install php-mbstring ;
	PHP=$(which php) ;
fi
if [ "$PHP" = "" ] ; then
	echo "PHP cli is missing. Please install package php-cli." ;
	exit 1;
fi

# ==============================================================================
# Download and Extract AlgoPanel Autoinstaller
# ==============================================================================
INSTALL_DIR=".";
if [ "$use_git" = false ] ; then

	echo "Downloading AlgoPanel Autoinstaller from ${AI_PACKAGE_URL}..."
	if [ "$CURL" != "" ] ; then
		$CURL -s -o /tmp/algopanel-ai.tar.gz "${AI_PACKAGE_URL}" >/dev/null 2>&1
	else
		$WGET -q -O /tmp/algopanel-ai.tar.gz "${AI_PACKAGE_URL}" >/dev/null 2>&1
	fi

	if [ ! -f "/tmp/algopanel-ai.tar.gz" ] ; then
		echo "Failed downloading Autoinstaller from ${AI_PACKAGE_URL}" ;
		exit 1;
	fi

	rm -rf /tmp/algopanel-ai ;
	mkdir -p /tmp/algopanel-ai ;
	tar -C /tmp/algopanel-ai/ -xzf /tmp/algopanel-ai.tar.gz || (echo "Failed extracting Autoinstaller" ; exit 1)
	rm -f /tmp/algopanel-ai.tar.gz ;
	cd /tmp/algopanel-ai ;
	INSTALL_DIR="/tmp/algopanel-ai";
fi

TTY=$(ps ax | grep "^[ ]*"$$ | head -n 1 | awk '{ print $2 }' 2>/dev/null);
if [ "$TTY" != "" ] ; then
	${PHP} -q "$INSTALL_DIR/ispconfig.ai.php" $@ < /dev/${TTY} ;
else 
	echo "It seems you are not using a TTY. Please add --i-know-what-i-am-doing to the arguments.";
	${PHP} -q "$INSTALL_DIR/ispconfig.ai.php" $@ ;
fi

cd ${CURDIR} ;
