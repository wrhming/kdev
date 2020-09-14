# $OSTYPE =~ [mac]^darwin, linux-gnu, [win]msys, FreeBSD, [termux]linux-android
# Darwin\ *64;Linux\ armv7*;Linux\ aarch64*;Linux\ *64;CYGWIN*\ *64;MINGW*\ *64;MSYS*\ *64

case $(uname -sm) in
  Darwin\ *64 )
    alias lns='ln -fs'
    function af { lsof -p $1 +r 1 &>/dev/null }
    alias osxattrd='xattr -r -d com.apple.quarantine'
    alias rmdss='find . -name ".DS_Store" -depth -exec rm {} \;'
    [[ -x $HOME/.iterm2_shell_integration.zsh ]]  && source $HOME/.iterm2_shell_integration.zsh
  ;;
  Linux\ *64 )
    alias lns='ln -fsr'
    function af { tail --pid=$1 -f /dev/null }
  ;;
  * )
    alias lns='ln -fsr'
  ;;
esac

compdef _kill af

if grep -q microsoft /proc/version; then
  #ps# Install-Module -Name BurntToast
  toast () { powershell.exe -command New-BurntToastNotification "-Text '$1'" }
fi

if (( $+commands[ip] )); then
  export route=$(ip route | awk 'NR==1 {print $3}')
else
  export route=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')
fi

if [ -n "$WSL_DISTRO_NAME" ]; then
  export DISPLAY=${route}:0.0
fi

function china_mirrors {
  case $(grep ^ID= /etc/os-release | sed 's/ID=\(.*\)/\1/') in
    ubuntu )
      cp /etc/apt/sources.list /etc/apt/sources.list.$(date +%y%m%d%H%M%S)
      sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    ;;
    debian )
      cp /etc/apt/sources.list /etc/apt/sources.list.$(date +%y%m%d%H%M%S)
      sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1ftp2.cn.debian.org\3main contrib non-free/g' /etc/apt/sources.list
    ;;
    alpine )
      cp /etc/apk/repositories /etc/apk/repositories.$(date +%y%m%d%H%M%S)
      sed -i 's/dl-cdn.alpinelinux.org/mirror.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
    ;;
    * )
  esac
}

function make-swapfile {
    local file="/root/swapfile"
    local size="16"
    local options=$(getopt -o f:s: -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
        -f)
            shift
            file=$1
            ;;
        -s)
            shift
            size=$1
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    dd if=/dev/zero of=$file bs=1M count=$((1024*${size})) # GB
    chmod 0600 $file
    mkswap $file
    swapon $file
    echo "$file swap swap defaults 0 2" >> /etc/fstab
}


function iptables---- {
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --dport 22,80,443 -j ACCEPT
    iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
    iptables -A INPUT -p tcp --dport 55555 -j ACCEPT
    iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -i wg0 -j ACCEPT
    iptables -P INPUT DROP
}

function iptables-allow-address {
    iptables -A INPUT -s $1 -j ACCEPT
}

function iptables-clean-input {
    iptables -P INPUT ACCEPT
    iptables -F
}

alias iptables-list-input="iptables -L INPUT --line-num -n"