# Evan's zsh config, ported from ~/dev/nix-config/dotfiles/.zshrc.
# Sourced after the shared terminal.nix config, so these win on conflicts.

# oh-my-zsh's git plugin defines aliases with some of the names used for
# functions below; drop them so the function definitions take effect.
unalias gcs gco gpr gpru gpr14 gpo gpi gap gas val back nvimp gitblames \
    osb osc clip_file cf e br red redset gitignore vol wd cwd cleanrs \
    em de der djs djsr djsrr lfcd 2>/dev/null

_comp_options+=(globdots) # Include hidden files.

# ---- vi mode -----------------------------------------------------------------
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes. Uses zle hooks so it chains with
# starship's own keymap-select widget instead of replacing it.
autoload -Uz add-zle-hook-widget
_evan_cursor_keymap() {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[1 q'
  else
    echo -ne '\e[5 q'
  fi
}
_evan_cursor_line_init() { echo -ne '\e[5 q' }
add-zle-hook-widget keymap-select _evan_cursor_keymap
add-zle-hook-widget line-init _evan_cursor_line_init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
autoload -Uz add-zsh-hook
_evan_cursor_preexec() { echo -ne '\e[5 q' }
add-zsh-hook preexec _evan_cursor_preexec

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# Edit line in $EDITOR with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

export EDITOR=vim
export VISUAL=vim
export COLORTERM=truecolor
export PATH="$PATH:$HOME/.local/bin"

# ---- cargo / clang-format ----------------------------------------------------
alias ctr='cargo test --profile release'
alias ctd='cargo test'
alias tcer='cargo build --profile release && time cargo run --profile release'
alias cer='cargo run --profile release'
alias ced='cargo run'
alias cpr='UPDATE_EXPECT=true cargo test --profile release'
alias cpd='UPDATE_EXPECT=true cargo test'
alias cfi='clang-format -i -style="{IndentWidth: 4, AlignConsecutiveAssignments: true, AlignConsecutiveDeclarations: true, BasedOnStyle: Google}"'
alias cfia='clang-format -i -style="{IndentWidth: 4, AlignConsecutiveAssignments: true, AlignConsecutiveDeclarations: true, BasedOnStyle: Google, BreakBeforeBraces: Allman}"'
alias rlib='cd ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/'

cleanrs() {
    for f in $(find . -name Cargo.toml | xargs dirname); do (cd $f; cargo clean; cargo fmt --all); done
}

# ---- git ---------------------------------------------------------------------
gcs () {
    git clone "git@github.com:/evan-a-w/$1"
}

alias gas='git add *; git add -u; git commit -m "😊"; git push'
alias gap='git pull'

gitblames() {
    if [ "$1" = "\n" ] || [ "$1" = "" ]; then
        echo "git ls-files | while read f; do git blame -w -M -C -C --line-porcelain $f | grep '^author '; done | sort -f | uniq -ic | sort -rn"
        git ls-files | while read f; do git blame -w -M -C -C --line-porcelain $f | grep '^author '; done | sort -f | uniq -ic | sort -rn;
    else
        echo "git ls-files | rg "$1" | while read f; do git blame -w -M -C -C --line-porcelain $f | grep '^author '; done | sort -f | uniq -ic | sort -rn"
        git ls-files | rg "$1" | while read f; do git blame -w -M -C -C --line-porcelain $f | grep '^author '; done | sort -f | uniq -ic | sort -rn
    fi
}

# Grab a .gitignore file from GitHub. Usage: gitignore [Language] (case-sensitive)
gitignore () {
    curl -s --fail "https://raw.githubusercontent.com/github/gitignore/main/$1.gitignore" -o .gitignore
    if [ $? -eq 0 ]; then
        return 0
    else
        echo "Lookup failed, maybe check capitalisation?"
        return 1
    fi
}

# ---- misc helpers ------------------------------------------------------------
val() {
    valgrind -q --leak-check=full "$@"
}

back() {
    (cd .. && "$@")
}

nvimp() {
    nvim -p $(find . | rg "$1")
}

alias ctg="ctags --recurse=yes --exclude=.git --exclude=BUILD --exclude=.svn"
alias cmake_lsp_gen="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ."

alias sys161kern="sys161 -p 16161 kernel"
alias sys161kernw="sys161 -p 16161 -w kernel"

osb() {
    p=`pwd`;
    cd "$HOME/cs3231/asst$1-src/kern/compile/ASST$1";
    bmake depend;
    bmake;
    bmake install;
    cd $p;
}

osc() {
    p=`pwd`;
    cd "$HOME/cs3231/asst$1-src/kern/compile/ASST$1";
    bmake && bmake install;
    cd $p;
}

# ---- C / C++ quick compile ---------------------------------------------------
gco() {
    filename="${1%.*}"
    g++ -o "${filename}" "$filename.c" "${@:2}" -Werror -Wall -g -Wshadow -lm -fsanitize=address
}

gpr() {
    filename="${1%.*}"
    clang++ -o "${filename}" "$filename.cpp" "${@:2}" -Werror -Wall -g -Wshadow -lm -fsanitize=address -std=gnu++2a && ./"${filename}"
}

gpru() {
    filename="${1%.*}"
    g++ -o "${filename}" "$filename.cpp" "${@:2}" -Werror -Wall -g -Wshadow -lm -std=gnu++2a && ./"${filename}"
}

gpr14() {
    filename="${1%.*}"
    g++ -o "${filename}" "$filename.cpp" "${@:2}" -Werror -Wall -g -Wshadow -lm -fsanitize=address -std=gnu++14 && ./"${filename}"
}

gpo() {
    filename="${1%.*}"
    g++ -o "${filename}" "$filename.cpp" "${@:2}" -Werror -Wall -g -Wshadow -lm -fsanitize=address -std=gnu++2a
}

gpi() {
    filename="${1%.*}"
    g++ -o "${filename}" "$filename.cpp" "${@:2}" -Werror -Wall -g -Wshadow -lm -fsanitize=address &&
    ./"${filename}" < "${filename}.in"
}

clip_file() {
    if [ -f "$1" ]; then
        cat "$1" | clip.exe
    else
        echo "File $1 does not exist"
    fi
}
alias cf='clip_file'

# ---- dune / OCaml ------------------------------------------------------------
alias dbe='dune exec bin/main.exe --profile release'
alias dbr='dune build @runtest'
alias dbrr='dune build @runtest --profile release'
alias dbrw='dune build @runtest --watch'
alias dbw='dune build --watch'
alias dbrwr='dune build @runtest --watch --profile release'
alias dbwr='dune build --watch --profile release'
alias dp='dune promote'

de() {
    dune exec bin/main.exe -- "$@"
}

der() {
    dune exec --release bin/main.exe -- "$@"
}

djs() {
    dune build bin/main.bc.js && prettier _build/default/bin/main.bc.js | pbcopy
}

djsr() {
    dune build --release bin/main.bc.js && prettier _build/default/bin/main.bc.js | pbcopy
}

djsrr() {
    dune build --release bin/main.bc.js && node _build/default/bin/main.bc.js
}

# ---- editors -----------------------------------------------------------------
e() {
    emacs -nw "$@"
}

em() {
  open /Applications/Emacs.app --args $(pwd)
}

# ---- system ------------------------------------------------------------------
alias usa="expressvpn connect \"United states\""
alias aus="expressvpn connect \"Australia\""

br() {
    sudo brightnessctl set "$@"
}
alias bright=br

export NIGHTTEMP=2500

redset() {
    export NIGHTTEMP="$1"
}

red() {
    if [ -n "$REDSHIFT" ]; then
        redshift -x
        export REDSHIFT=""
    else
        redshift -O "$NIGHTTEMP"
        export REDSHIFT=ON
    fi
}

touchres() {
    if [ -e /tmp/mouse-disabled ]; then
        rm -f /tmp/mouse-disabled
        xinput enable 12
    else
        touch /tmp/mouse-disabled
        xinput enable 12
    fi;
}

vol() {
    amixer -D pulse sset Master "$@"
}

wd() {
    echo $(pwd) > ~/.workdir
}

cwd() {
    cd $(cat ~/.workdir)
}

psql_env() {
    source ~/dev/psql/env
    cd ~/dev/psql/bin
}

psql_start() {
    ~/psql/bin/pg_ctl start -l "$PGDATA/log"
}

psql_stop() {
    ~/psql/bin/pg_ctl stop
}

alias chatgpt-restart='pkill ms-playwright/firefox && chatgpt install'
alias pi=~/dev/pi/pi-test.sh
alias fixdns="sudo killall pia-daemon; sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1; sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Fix D-Bus for SSH sessions
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -d "/run/user/$(id -u)" ]; then
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
fi

alias nzsh='nix-shell --run zsh'
alias hs='nh home switch'
alias ns='nh os switch'
