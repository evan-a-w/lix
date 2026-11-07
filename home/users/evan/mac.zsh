# macOS-only zsh additions, ported from the pre-lix ~/.zshrc.
# Sourced after zshrc.zsh (see mac.nix), so these win on conflicts.

# Homebrew's shellenv is in ~/.zprofile (profileExtra in mac.nix).

# macOS's /etc/zprofile runs path_helper, which shoves /usr/local/bin and
# friends ahead of the nix paths ~/.zshenv set up (and nix-daemon.sh won't
# re-run in /etc/zshrc). Put nix back in front; brew llvm etc. below still
# go ahead of it on purpose.
path=("$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin $path)
typeset -U path

# opam (global switch outside nix; per-project OCaml should come from direnv)
if [ -r "$HOME/.opam/opam-init/init.zsh" ]; then
  . "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>&1 || true
fi

[ -d /opt/homebrew/opt/llvm/bin ] && export PATH=/opt/homebrew/opt/llvm/bin:$PATH
[ -d /opt/homebrew/opt/zstd/bin ] && export PATH=/opt/homebrew/opt/zstd/bin:$PATH

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="$HOME/.local/bin:$PATH"

(( $+commands[sccache] )) && export RUSTC_WRAPPER=sccache

# GUI emacs from home-manager (copied to ~/Applications/Home Manager Apps)
em() {
  open -a "$HOME/Applications/Home Manager Apps/Emacs.app" --args "$(pwd)"
}

alias lloydserver='ssh lloydserver@lloydw.duckdns.org -p 143'

profile_dimacs() {
    local instance="${1:-SUBSETS_100}"
    local trace="/tmp/${instance}.trace"
    local xml="/tmp/${instance}_time_profile.xml"

    OCAMLPARAM='_,g=1' dune build --profile release bench/dimacs_debug.exe

    xcrun xctrace record \
      --template 'Time Profiler' \
      --output "$trace" \
      --time-limit 40s \
      --launch -- _build/default/bench/dimacs_debug.exe -instance "$instance" || return 1

    xcrun xctrace export \
      --input "$trace" \
      --xpath '/trace-toc/run/data/table[@schema="time-profile"]' \
      --output "$xml" || return 1

    python3 - "$xml" <<EOF
import sys
import xml.etree.ElementTree as ET
from collections import Counter

xml = sys.argv[1]
root = ET.parse(xml).getroot()
node = root.find('node')

backtrace_first = {}
counts = Counter()

for row in node.findall('row'):
    bt = row.find('backtrace')
    if bt is None:
        continue
    name = None
    ref = bt.get('ref')
    if ref is not None:
        name = backtrace_first.get(ref)
    else:
        frames = bt.findall('frame')
        if frames:
            name = frames[0].get('name')
        bt_id = bt.get('id')
        if bt_id is not None:
            backtrace_first[bt_id] = name
    if name:
        counts[name] += 1

total = sum(counts.values())
for name, count in counts.most_common(30):
    print(f"{count:5d} {100.0*count/total:6.2f}% {name}")
EOF
}



profile_simple_sat_dimacs() {
    local instance="${1:-SUBSETS_100}"
    local trace="${instance}.simple_sat.trace"
    local xml="/tmp/${instance}_simple_sat_time_profile.xml"

    OCAMLPARAM='_,g=1' dune build --profile release bench/simple_sat_dimacs_debug.exe

    xcrun xctrace record \
      --template 'Time Profiler' \
      --output "$trace" \
      --time-limit 40s \
      --launch -- _build/default/bench/simple_sat_dimacs_debug.exe -instance "$instance" || return 1

    xcrun xctrace export \
      --input "$trace" \
      --xpath '/trace-toc/run/data/table[@schema="time-profile"]' \
      --output "$xml" || return 1

    python3 - "$xml" <<EOF
import sys
import xml.etree.ElementTree as ET
from collections import Counter

xml = sys.argv[1]
root = ET.parse(xml).getroot()
node = root.find('node')

backtrace_first = {}
counts = Counter()

for row in node.findall('row'):
    bt = row.find('backtrace')
    if bt is None:
        continue
    name = None
    ref = bt.get('ref')
    if ref is not None:
        name = backtrace_first.get(ref)
    else:
        frames = bt.findall('frame')
        if frames:
            name = frames[0].get('name')
        bt_id = bt.get('id')
        if bt_id is not None:
            backtrace_first[bt_id] = name
    if name:
        counts[name] += 1

total = sum(counts.values())
for name, count in counts.most_common(30):
    print(f"{count:5d} {100.0*count/total:6.2f}% {name}")
EOF
  }


alias kimi-claude='env ANTHROPIC_BASE_URL="https://api.kimi.com/coding/" ANTHROPIC_API_KEY="$(<"$HOME/.secrets/kimi.key")" ANTHROPIC_MODEL="k3-256k" ANTHROPIC_DEFAULT_FABLE_MODEL="k3-256k" ANTHROPIC_DEFAULT_OPUS_MODEL="k3-256k" ANTHROPIC_DEFAULT_SONNET_MODEL="k3-256k" ANTHROPIC_DEFAULT_HAIKU_MODEL="k3-256k" CLAUDE_CODE_SUBAGENT_MODEL="k3-256k" CLAUDE_CODE_EFFORT_LEVEL="high" CLAUDE_CODE_AUTO_COMPACT_WINDOW="262144" CLAUDE_CODE_MAX_CONTEXT_TOKENS="262144" claude'

alias pi=~/dev/pi/pi-test.sh
