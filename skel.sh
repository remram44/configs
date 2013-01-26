if [ "$PWD" != "$HOME" ] ; then
    echo "Error: this script should be run from your HOME"
    exit 1
fi


####################
# Setup rc files
#
cat > .vimrc <<END
syntax on
set expandtab
set softtabstop=4
set tabstop=4
set cindent
set shiftwidth=4
END

cat > .screenrc <<END
termcapinfo xterm ti@:te@
startup_message off
shell /bin/bash
defhstatus "screen ^E (^Et) | $USER@^EH"
hardstatus off
END


####################
# This one is done manually
#
# We show my usual aliases and want for enter to be pressed, then launch the
# editor
#
cat <<END
alias ll='ls -lh'
alias la='ls -lAh'
alias ifconfig='/sbin/ifconfig'

Press enter to run 'vim .bashrc'
END
read && vim .bashrc && . .bashrc


####################
# Setup SSH keys
#
mkdir .ssh
cat > .ssh/authorized_keys <<END
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAwrqlmGDryX2FA4Rdd8A98/25WDtr7MDyTpXSaGqjuytPNV2tmokvPOYGwMBYKlJlE6rd8+GqrKu+/WVhOjGD/kPWA1PUMZmvfz0M610QoR7SASts2FuFBW2NZNjKSssTJcVrsO0kJoW5nELzyYYW+VWA1IMW0ege0bTD6V7EfSc= Rasus
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLKUaDEEVuj/kBKiJsDBvrkgjkXGPmoPR6K3Gq/5DiM/IyIxZ4SdfHGyxJs7W4fDZOKZIxQtKpnZ/vqs9Bcb1rF3lbFsrkxKP4d/mGNbYh8YvpU+ZVKFHiEMBTNSP//AJiiS9x2nfZE3AwEDBTnTJKGRVdtyTXKCy6CGSdL0FSyf/ES6YYi53uS4EOHaeXogDJvsxy9L0ekfS2H8/xsGlnjWofWtBcSGpFIc4b0hbDz8XP76T9qGavHR0tuexKMMYdm3bOtTHI6OeaW9703Qi4vmdAJ+91Ar3oI5hJjoGdnw3ctDiBFL10I5tMCNjZP3yeSM4dMNAnENj78JdPIx3p Android
END


####################
# Install a package with aptitude
#
# The trick is on sudo, which might not be available; we default to su -c
#
install_pkgs() {

if dpkg -l | grep --silent "ii  sudo "; then
    sudo aptitude install $*
else
    su -c "aptitude install $*"
fi

}


####################
# Debian packages
#
check_deb_pkgs() {

local REQUIRED=$(cat <<END
console-data openssh-client openssh-server wget zip unzip dnsutils dialog
debfoster sudo vim screen apt-file netcat tcpdump dig lshw gnupg openssl
END
)

local DEBIAN_VERSION="$(cat /etc/debian_version)"
echo "Debian detected; version is $DEBIAN_VERSION"

# Check the presence of required packages
local FOUND=0
local NOT_FOUND=''
for pkg in $REQUIRED; do
    if dpkg -l | grep --silent "ii  $pkg "; then
        FOUND=$((FOUND + 1))
    else
        NOT_FOUND="$SKEL_NOT_FOUND $pkg"
    fi
done
if [ "x$NOT_FOUND" != x ] ; then
    echo "found $FOUND/$(echo $REQUIRED | wc --words) required packages; installing"
    install_pkgs $NOT_FOUND
fi

# Propose additional package lists
propose_package "development" "build-essential g++ gdb lua5.1 make
        sqlite3 git mercurial"
propose_package "web server" "apache2"

}


####################
# Propose a list of packages to be installed
#
propose_package() {

echo -n "Should I install the package: $1? [y/N] "
local rep
read rep
shift
if [ "x$rep" == "xy" ] || [ "x$rep" == "xY" ] ; then
    install_pkgs $*
fi

}


if [ -f /etc/debian_version ] ; then
    check_deb_pkgs
fi


####################
# Check the locale settings
#
check_locales() {

echo -n "Would you like to review locale settings? [Y/n] "
local rep
read rep
if [ "x$rep" == "x" ] || [ "x$rep" == "xy" ] || [ "x$rep" == "xY" ] ; then
    locale
    echo
    echo "Reasonable values:  fr_FR.UTF-8  en_US.UTF-8"
    echo
    echo -n "Press enter or type a new value for LANG: "
    read rep
    if [ "x$rep" == x ] ; then
        echo "Keeping locale settings"
    else
        echo >> .profile
        echo "# Locale settings" >> .profile
        echo "export LANG='$rep'" >> .profile
    fi
fi

}
check_locales


####################
# Check the date/timezone settings
#
check_date() {

echo -n "Would you like to review date/timezone settings? [Y/n] "
local rep
read rep
if [ "x$rep" == "x" ] || [ "x$rep" == "xy" ] || [ "x$rep" == "xY" ] ; then
    if [ "x$TZ" == x ] ; then
        echo "TZ is not set"
    else
        echo "TZ is $TZ"
    fi
    echo -n "Run tzselect? [Y/n] "
    read rep
    if [ "x$rep" == "x" ] || [ "x$rep" == "xy" ] || [ "x$rep" == "xY" ] ; then
        ZONE=$(tzselect)
        if [ "xTZ" != x ] ; then
            echo >> .profile
            echo "# Timezone" >> .profile
            echo "export TZ='$ZONE'" >> .profile
        fi
    fi
    TZ=$ZONE date
else
    echo "Skipping timezone setup"
fi

}
check_date
