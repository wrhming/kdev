user-tab(){
    case $BUFFER in
        "" )                       # "" -> "cd "
            BUFFER="cd "
            zle end-of-line
            zle expand-or-complete
            ;;
        " " )
            if [ -f Taskfile.yml ]; then
                BUFFER="task "
            elif [ -f justfile ]; then
                BUFFER="just "
            elif [ -f Makefile ]; then
                BUFFER="make "
            else
                return
            fi
            zle end-of-line
            zle expand-or-complete
            ;;
        "cd --" )                  # "cd --" -> "cd +"
            BUFFER="cd +"
            zle end-of-line
            zle expand-or-complete
            ;;
        "cd +-" )                  # "cd +-" -> "cd -"
            BUFFER="cd -"
            zle end-of-line
            zle expand-or-complete
            ;;
        * )
            zle expand-or-complete
            ;;
    esac
}
zle -N user-tab
bindkey "\t" user-tab

user-ret(){
    if [[ $BUFFER = "" ]]; then
        BUFFER="ls"
        zle end-of-line
        zle accept-line
    elif [[ $BUFFER = " " ]]; then
        BUFFER="ls -lh"
        zle end-of-line
        zle accept-line
    elif [[ $BUFFER = "  " ]]; then
        BUFFER="ls -lah"
        zle end-of-line
        zle accept-line
    elif [[ $BUFFER =~ "\.\.\.+" ]]; then
        # <1> . -> ../ <2> " ../" -> " " <3> // -> /
        BUFFER=${${${BUFFER//\./\.\.\/}// \.\.\// }//\/\//\/}
        zle end-of-line
        zle accept-line
    else
        zle accept-line
    fi
}
zle -N user-ret
bindkey "\r" user-ret

user-spc(){
    # cursor (behind && over) space && not behind ~
    if [[ $LBUFFER =~ ".*[^ ~] +$" ]] && [[ ( $RBUFFER == "" ) || ( $RBUFFER =~ "^ .*" ) ]]; then
        LBUFFER=${LBUFFER}"~"
        zle backward-char
        zle forward-char
        zle expand-or-complete
    else
        zle magic-space
    fi
}
zle -N user-spc
bindkey " " user-spc

user-bspc-word(){
    if [[ $BUFFER = "" ]]; then
        BUFFER="popd"
        zle accept-line
    else
        zle backward-kill-word
    fi
}
zle -N user-bspc-word
bindkey "\C-w" user-bspc-word

user-bspc(){
    if [[ $BUFFER = "" ]]; then
        BUFFER="cd .."
        zle accept-line
    else
        zle backward-delete-char
    fi
}
zle -N user-bspc
bindkey "\C-h" user-bspc

user-esc() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    elif [[ $BUFFER == $EDITOR\ * ]]; then
        LBUFFER="${LBUFFER#$EDITOR }"
        LBUFFER="sudoedit $LBUFFER"
    elif [[ $BUFFER == sudoedit\ * ]]; then
        LBUFFER="${LBUFFER#sudoedit }"
        LBUFFER="$EDITOR $LBUFFER"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N user-esc
bindkey "\e\e" user-esc

bindkey "\C-q" push-line-or-edit
bindkey "^[q" quote-line
#bindkey "\C-r" history-incremental-pattern-search-backward
#bindkey "\C-s" history-incremental-pattern-search-forward
