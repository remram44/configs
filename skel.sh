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

cat > .gitconfig <<END
[user]
	name = Remi Rampin
	email = remirampin@gmail.com
[merge]
	conflictstyle = diff3
	defaultToUpstream = true
[alias]
	np = !sh -c 'git log --graph --decorate --branches --not --remotes=$1' -
	serve = !git daemon --reuseaddr --verbose  --base-path=. --export-all ./.git
	fa = !git fetch --all -p && git submodule foreach git fetch --all -p
	p = !git merge --ff-only
	bdiff = !sh -c 'git difftool --dir-diff $(git merge-base $1 $2)..$2' -
END


####################
# This one is done manually
#
# We show my usual aliases and wait for enter to be pressed, then launch the
# editor
#
cat <<END
alias ll='ls -lh'
alias la='ls -lAh'
alias ifconfig='/sbin/ifconfig'
a(){
    source "$1/bin/activate"
}

Press enter to run 'vim .bashrc'
END
read && vi .bashrc && . .bashrc


####################
# Setup SSH keys
#
mkdir .ssh
cat > .ssh/authorized_keys <<END
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAwrqlmGDryX2FA4Rdd8A98/25WDtr7MDyTpXSaGqjuytPNV2tmokvPOYGwMBYKlJlE6rd8+GqrKu+/WVhOjGD/kPWA1PUMZmvfz0M610QoR7SASts2FuFBW2NZNjKSssTJcVrsO0kJoW5nELzyYYW+VWA1IMW0ege0bTD6V7EfSc= Rasus
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAtwykPMe1ypsoLwk4nXlVYJK1F/gPJ2f9AXGQgNkJkNXQ4iGJt0UoMtCRcSWRqAmTosILWmAeQsHDkSObXgkqYypDgkKuE7quP0557kj8bclyMWKfCqrPZz/amxJ7PGfTzx6T5Z+3bbLf2GJGcYzKUheF7caCgFLs0nEQuwVxPQM= Nexus4
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
console-data openssh-client openssh-server wget zip unzip dnsutils dialog mosh
debfoster sudo vim screen apt-file netcat tcpdump dnsutils lshw gnupg openssl
moreutils pv molly-guard
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
        NOT_FOUND="$NOT_FOUND $pkg"
    fi
done
if [ "x$NOT_FOUND" != x ] ; then
    echo "found $FOUND/$(echo $REQUIRED | wc --words) required packages; installing"
    install_pkgs $NOT_FOUND
else
    echo "found $FOUND/$(echo $REQUIRED | wc --words) required packages; moving on"
fi

# Propose additional package lists
propose_package "development" "build-essential pkg-config g++ gdb lua5.1 make
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
else
    echo "Skipping locale setup"
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
    export TZ=$ZONE
    date
else
    echo "Skipping timezone setup"
fi

}
check_date
