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

cat <<END
alias ll='ls -lh'
alias la='ls -lAh'
alias sudo='sudo -E'
alias ifconfig='/sbin/ifconfig'
END
read && vim .bashrc && . .bashrc

mkdir .ssh
cat > .ssh/authorized_keys <<END
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAwrqlmGDryX2FA4Rdd8A98/25WDtr7MDyTpXSaGqjuytPNV2tmokvPOYGwMBYKlJlE6rd8+GqrKu+/WVhOjGD/kPWA1PUMZmvfz0M610QoR7SASts2FuFBW2NZNjKSssTJcVrsO0kJoW5nELzyYYW+VWA1IMW0ege0bTD6V7EfSc= Rasus
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLKUaDEEVuj/kBKiJsDBvrkgjkXGPmoPR6K3Gq/5DiM/IyIxZ4SdfHGyxJs7W4fDZOKZIxQtKpnZ/vqs9Bcb1rF3lbFsrkxKP4d/mGNbYh8YvpU+ZVKFHiEMBTNSP//AJiiS9x2nfZE3AwEDBTnTJKGRVdtyTXKCy6CGSdL0FSyf/ES6YYi53uS4EOHaeXogDJvsxy9L0ekfS2H8/xsGlnjWofWtBcSGpFIc4b0hbDz8XP76T9qGavHR0tuexKMMYdm3bOtTHI6OeaW9703Qi4vmdAJ+91Ar3oI5hJjoGdnw3ctDiBFL10I5tMCNjZP3yeSM4dMNAnENj78JdPIx3p Android
END
