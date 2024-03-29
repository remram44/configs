if [ "$PWD" != "$HOME" ] ; then
    echo "Error: this script should be run from your HOME" >&2
    exit 1
fi


####################
# Setup rc files
#
cat > .vimrc <<'END'
syntax on
set tabstop=4       " Real tabs take up 4 spaces
set softtabstop=4   "   but indent by 4 when pressing tab
set expandtab       " Use spaces when pressing tab
set shiftwidth=4    "   and shift by 4 spaces when indenting
set cindent
set indentkeys=o,O  " Don't re-indent current line
set hidden          " Allow hidden buffers
set backspace=indent,eol,start
set autoread        " Re-load files changed outside of ViM

set linebreak       " Use word-wrap
set showbreak=»\    "   with indicator
set breakindent     "  and original line's indent

set updatetime=2000 " Undo breakpoint when you pause typing 2s

set nocompatible
set mouse=a
set visualbell

let mapleader = ","

nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>
" qq records, Q replays
nnoremap Q @q

set incsearch
set hlsearch
set ignorecase
set smartcase
set laststatus=2
set scrolloff=4
set splitright

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Highlight EOL whitespace, http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=darkred guibg=#382424
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" The above flashes annoyingly while typing, be calmer in insert mode
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'rust-lang/rust.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'peitalin/vim-jsx-typescript'
Plugin 'dense-analysis/ale'
Plugin 'neoclide/coc.nvim'
call vundle#end()
filetype plugin indent on

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard | sort -u && git submodule foreach "git ls-files -co --exclude-standard | while read i; do echo \"\$path/\$i\"; done" | sort -u']
let g:ctrlp_switch_buffer = ''
noremap <leader>t :!ctags -R .<CR>
noremap <leader>p :CtrlPTag<CR>
noremap <leader>s :NERDTreeToggle<CR>
noremap <leader>f :NERDTreeFind<CR>
END

cat > .screenrc <<'END'
termcapinfo xterm ti@:te@
startup_message off
shell /bin/bash
defhstatus "screen ^E (^Et) | $USER@^EH"
hardstatus off
END

cat > .sqliterc <<'END'
.headers on
.mode column
END

cat > .gitconfig <<'END'
[user]
	name = Remi Rampin
	email = remi@rampin.org
	signingkey = 0x850C4075
[difftool "kdiff3"]
	path = kdiff3
	trustExitCode = false
[difftool]
	prompt = false
[diff]
	tool = kdiff3
	algorithm = histogram
[mergetool "kdiff3"]
	path = kdiff3
	trustExitCode = false
[mergetool]
	keepBackup = false
[merge]
	tool = kdiff3
	conflictstyle = diff3
	defaultToUpstream = true
	ff = false
[rebase]
	autoSquash = true
[push]
	default = simple
[log]
	date = iso
[alias]
	co = checkout
	pushf = push --force-with-lease
	np = !sh -c 'git log --graph --decorate --branches --not --remotes=$1' -
	serve = !git daemon --reuseaddr --verbose  --base-path=. --export-all ./.git
	f = fetch -p
	fa = !git fetch --all -p && git submodule foreach git fetch --all -p
	p = !git merge --ff-only
	dd = !git difftool --dir-diff
	bdiff = !sh -c 'git difftool --dir-diff $(git merge-base $1 $2)..$2' -
	lg = !git log --oneline --graph --decorate
	k = !gitk --all &
	cp = cherry-pick
	st = status
	detach = !git checkout HEAD~0
	uref = !sh -c 'git update-ref refs/heads/$1 $2 $1' -
[credential "https://git.rampin.org"]
	username = remi
	helper = !sh -c '[ "$1" = get ] && printf "password=%s" "$(pass show git.rampin.org | head -n 1)"' -
END


####################
# This one is done manually
#
# We show my usual aliases and wait for enter to be pressed, then launch the
# editor
#
cat <<'END'
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000000
HISTFILESIZE=2000000

HISTTIMEFORMAT='%F %T '

# Catch text mistakenly pasted in the terminal
bind 'set enable-bracketed-paste on'

# Make sure xterm-256color sets color_prompt


export VIRTUAL_ENV_DISABLE_PROMPT=1
if [ "$color_prompt" = yes ]; then
    case $(hostname) in
        missy) _HOSTCOLOR='1;33' ;;
        axon) _HOSTCOLOR='1;32' ;;
        spire) _HOSTCOLOR='1;31' ;;
        tanis) _HOSTCOLOR='1;34' ;;
        *) _HOSTCOLOR='1;37' ;;
    esac
    PS1='\n'\
'`s=$?; if [ $s != 0 ]; then echo "\[\033[7;31;40m\][e: $s]\[\033[0m\] "; fi`'\
'`if [ "x$CONDA_PREFIX" != x ]; then echo "\[\033[1;32;40m\][conda: $(basename $CONDA_PREFIX)]\[\033[0m\] "; fi`'\
'`if [ "x$VIRTUAL_ENV" != x ]; then echo "\[\033[1;32;40m\][py: $(basename $VIRTUAL_ENV)]\[\033[0m\] "; fi`'\
'`if [ "x$KUBECONFIG" != x ]; then echo "\[\033[1;32;40m\][k8s: $(basename "$KUBECONFIG")]\[\033[0m\] "; fi`'\
'`j=$(jobs | wc -l | xargs); if [ $j != 0 ]; then echo "\[\033[1;32m\][$j jobs] "; fi`'\
'`if SUDO_ASKPASS=/bin/false sudo -A -v >/dev/null 2>&1; then echo "\[\033[1;33;46m\]SUDO\[\033[0m\] "; fi`'\
'`if id -nG | grep -q docker; then echo "\[\033[1;33;46m\]DOCKER\[\033[0m\] "; fi`'\
'\[\033[`if [ "\u" = root ]; then echo "1;33;45"; elif [ "\u" = remram ]; then echo "1;36"; else echo "1;35"; fi`m\]\u'\
'\[\033[1;37m\]\[\033[0;36m\] `date "+%H:%M:%S"`\n'\
'\[\033['$_HOSTCOLOR'm\]\h \w'\
'`if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then if [ $(git rev-parse --is-inside-work-tree) = true ]; then echo " ($(git rev-parse --abbrev-ref HEAD 2>/dev/null))"; fi; fi`'\
'$\[\033[0m\] '
else
    PS1='\n'\
'`s=$?; if [ $s != 0 ]; then echo "[e: $s] "; fi`'\
'`if [ "x$CONDA_PREFIX" != x ]; then echo "[py: $(basename $CONDA_PREFIX)] "; fi`'\
'`if [ "x$VIRTUAL_ENV" != x ]; then echo "[py: $(basename $VIRTUAL_ENV)] "; fi`'\
'`if [ "x$KUBECONFIG" != x ]; then echo "[k8s: $(basename "$KUBECONFIG")] "; fi`'\
'`j=$(jobs | wc -l | xargs); if [ $j != 0 ]; then echo "[$j jobs] "; fi`'\
'`if id -nG | grep -q docker; then echo "DOCKER "; fi`'\
'\u'\
' `date "+%H:%M:%S"`\n'\
'\h \w'\
'`if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then if [ $(git rev-parse --is-inside-work-tree) = true ]; then echo " ($(git rev-parse --abbrev-ref HEAD 2>/dev/null))"; fi; fi`$ '
fi
if [ -n "$PRESENTATION" ]; then
    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
fi


alias sudo='sudo '
alias ll='ls -lh'
alias la='ls -lAh'
alias cv='cat -v'
alias ifconfig='/sbin/ifconfig'
alias rs='rsync -avz --partial --progress'
alias sshp='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'
alias k='kubectl'
alias ffprobe='ffprobe -hide_banner'
alias ffmpeg='ffmpeg -hide_banner'
alias xcopy='xclip -in -selection clipboard'
alias xpaste='xclip -out -selection clipboard'
o(){
    for i in "$@"; do
        xdg-open "$i" >/dev/null 2>&1
    done
}
trash(){
    for i in "$@"; do
        kioclient5 move "$i" trash:/
    done
}
a(){
    source "$1/bin/activate"
}
sudocker(){
    sudo -g docker -E env PATH="$PATH" "$@"
}
_sudocker_maybe(){
    if [ "x$DOCKER_HOST" != x ] || id -nG | grep -q '\bdocker\b'; then
        command "$@"
    else
        sudocker "$@"
    fi
}
docker(){
    _sudocker_maybe docker "$@"
}
docker-compose(){
    _sudocker_maybe docker-compose "$@"
}
KUBECONFIG=
export KUBECONFIG
(cd; if [ -e .kube/config ]; then echo "WARNING: kube config is set" >&2; fi)
kubea(){
    # When adding configs to configs/ from gcloud, you can add --account=...
    # to cmd-args to make it work regardless of global account set in gcloud
    if [ "$#" = 1 ]; then
        if [ ! -e ~/.kube/configs/"$1" ]; then echo "Config does not exist" >&2; return 1; fi
        KUBECONFIG=~/.kube/configs/"$1"
    else
        ls -1 ~/.kube/configs/
        KUBECONFIG=
    fi
}
ka(){
    if [ "$#" = 0 ]; then
        echo "No argument specified" >&2
        return 1
    else
        for arg in "$@"; do
            kubectl apply -f "$arg"
        done
    fi
}

dockviz(){
    if [ -n "$DOCKER_HOST" ]; then
        curl --cert "$DOCKER_CERT_PATH/cert.pem" --key "$DOCKER_CERT_PATH/key.pem" -k "https://$(echo $DOCKER_HOST | sed 's/tcp:\/\///')/images/json?all=1" | docker run -i --rm nate/dockviz images --tree --stdin
    else
        curl --unix-socket /var/run/docker.sock -k "http://localhost/images/json?all=1" | docker run -i --rm nate/dockviz images --tree --stdin
    fi
}
setmonitor(){
    if [ "$1" = "left" ]; then
        xrandr --output DP-1-2 --left-of eDP-1
    elif [ "$1" = "right" ]; then
        xrandr --output DP-1-2 --right-of eDP-1
    else
        echo "Usage: setmonitor <left|right>" >&2
        return 1
    fi
}
et(){
    if [ -z "$1" ]; then
        date +'%Z %z'
    else
        date -d "$1" +'%Z %z'
    fi
}
if type thefuck &>/dev/null; then
    eval $(thefuck --alias)
fi

Press enter to run 'vim .bashrc'
END
read && vi .bashrc && . .bashrc


####################
# Setup SSH keys
#
mkdir .ssh
if [ -s .ssh/authorized_keys ]; then
    echo "Warning: authorized_keys exists. Appending our keys anyway." >&2
fi
cat >> .ssh/authorized_keys <<'END'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8q5UxU/iOJUj7tRFKAPhRg5iHI6dfPfzOfEaSmJI9Y5Nm+Jlk7E98bVaxhwehOHQjfswzrrToyH/VNxrmpmppflu3d+WP0e6gqxAqMyQVH9GKgWv3TLNCh1VrykWEWjCArLcWy9xXhLYOKdKZ7x2oly4xPnaUWAnh8QE1OTIOZzlJcG0Jopd091ZCh9eqgVF28tqa056eru6l7BEjQz30imA+OGbl7U2gEStJpvBcEDjBDCnsnh/FCWMwI2SF4ypqOV1gCWTNni+QEBqLC+8P4hkXnz7NRAuubK4HmWB4UXZWF9DK4vN78SVFRlRabNncQYMAJiLDtOo3TCNGtdDH rr4_remram_missy
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAtwykPMe1ypsoLwk4nXlVYJK1F/gPJ2f9AXGQgNkJkNXQ4iGJt0UoMtCRcSWRqAmTosILWmAeQsHDkSObXgkqYypDgkKuE7quP0557kj8bclyMWKfCqrPZz/amxJ7PGfTzx6T5Z+3bbLf2GJGcYzKUheF7caCgFLs0nEQuwVxPQM= rr4_remram_nexus4
END

if ! [ -f .ssh/config ]; then
    cat >> .ssh/config <<'END'
ServerAliveInterval 120
AddKeysToAgent confirm
END
fi


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

local REQUIRED=$(cat <<'END'
console-data openssh-client openssh-server wget zip unzip dnsutils dialog mosh
debfoster sudo vim screen apt-file netcat tcpdump dnsutils lshw gnupg openssl
moreutils pv molly-guard bash-completion
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
        sqlite3 git mercurial python python-pip python-virtualenv python-dev"
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
    if ! dpkg -l | grep --silent 'ii aptitude'; then
        if dpkg -l | grep --silent "ii  sudo "; then
            sudo apt-get install aptitude
        else
            su -c "apt-get install aptitude"
        fi
    fi
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
        if [ "x$TZ" != x ] ; then
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
