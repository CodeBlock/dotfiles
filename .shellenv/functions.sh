# Misc functions

function pushj {
  pushd "$(j -b "$1")"
}

function upload {
  if [ ! -f "$1"  -a  ! -d "$1" ]; then
    return 1
  fi
  if [ "$2" != "" ]; then
    destination="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$2")"
  else
    destination="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$(basename "$1")")"
  fi
  rsync --progress --partial -avzre ssh "$1" elrod.me:/srv/webmount/tmp/"$destination" &&
    echo "http://tmp.elrod.me/$destination"
}

function parse_git_branch {
  command git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function ghpages-init {
    if [ "$1" == "" ]; then
        echo "Usage: ghpages-init \$1"
        return 1
    fi
    dir="$(mktemp -d)"
    git clone "ssh://github.com:$1" "$dir/repo"
    pushd "$dir/repo"
    git ls-remote | grep gh-pages
    if [ $? == 0 ]; then
        echo "gh-pages exists already. Aborting!"
        popd
        rm -rf "$dir"
        return 1
    else
        git checkout --orphan gh-pages
        git rm -rf .
        echo "hello!" > index.html
        git add index.html
        git commit -m 'Initialize gh-pages'
        git push origin gh-pages
        popd
        rm -rf "$dir"
    fi
}

# This lets us do multiple invocations of some single command with different
# arugments. For example, `cabal` has no way to combine commands, e.g.
# `cabal clean build`. You end up needing to do `cabal clean && cabal build`.
function s {
  cmd=""
  ran=0
  for i in "$@"; do
    if [ $ran -eq 0 ]; then
      ran=1
      cmd="$i"
    else
      $1 $i
      if [ $? != 0 ]; then
        break
      else
        continue
      fi
    fi
  done
}

# This does the same thing as `s` above, except it doesn't bail out if one of
# the commands fails.
function ss {
  cmd=""
  ran=0
  for i in "$@"; do
    if [ $ran -eq 0 ]; then
      ran=1
      cmd="$i"
    else
      $1 $i
    fi
  done
}