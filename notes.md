## BUILD

### https://github.com/github/hub/blob/master/script/build

#!/usr/bin/env bash
# vi:ft=sh:
# Usage: script/build [-o <EXE>]
#        script/build test
#
# Sets up GOPATH and compiles hub to <EXE> (default: `bin/hub`).
#
# With `test`, runs tests instead.

set -e

windows=
[[ $OS == Windows* ]] && windows=1

setup_gopath() {
  TMPDIR="${LOCALAPPDATA:-$TMPDIR}"
  TMP_GOPATH="${TMPDIR:-/tmp}/go"
  TMP_SELF="${TMP_GOPATH}/src/github.com/github/hub"

  if [ -n "$windows" ]; then
    export GOPATH="${TMP_GOPATH//\//\\}"
  else
    export GOPATH="$TMP_GOPATH"
  fi

  export GO15VENDOREXPERIMENT=1

  mkdir -p "${TMP_SELF%/*}"
  ln -snf "$PWD" "$TMP_SELF" 2>/dev/null || {
    rm -rf "$TMP_SELF"
    mkdir "$TMP_SELF"
    cp -R "$PWD"/* "${TMP_SELF}/"
  }
}

find_source_files() {
  find . -maxdepth 2 -name '*.go' '!' -name '*_test.go' "$@"
}

find_packages() {
  find_source_files | cut -d/ -f2 | sort -u | grep -v '.go$' | sed 's!^!github.com/github/hub/!'
}

build_hub() {
  setup_gopath
  mkdir -p "$(dirname "$1")"
  go build -ldflags "-X github.com/github/hub/version.Version=`./script/version`" -o "$1"
}

test_hub() {
  setup_gopath
  find_packages | xargs go test
}

[ $# -gt 0 ] || set -- -o "bin/hub${windows:+.exe}"

case "$1" in
-o )
  shift
  if [ -z "$1" ]; then
    echo "error: argument needed for \`-o'" >&2
    exit 1
  fi
  build_hub "$1"
  ;;
test )
  test_hub
  ;;
files )
  find_source_files
  ;;
-h | --help )
  sed -ne '/^#/!q;s/.\{1,2\}//;1,2d;p' < "$0"
  exit
  ;;
* )
  "$0" --help >&2
  exit 1
esac


## CIBUILD

### https://github.com/octokit/octokit.rb/blob/master/script/cibuild

#!/bin/sh

set -e

script/test


###  https://github.com/github/github-services/blob/master/script/cibuild

#!/bin/sh
# Usage: script/test
# Runs the library's CI suite.

test -d "/usr/share/rbenv/shims" && {
  export PATH=/usr/share/rbenv/shims:$PATH
  export RBENV_VERSION="2.1.7-github"
}

script/bootstrap
bundle exec rake test


### https://github.com/github/brubeck/blob/master/script/cibuild

#!/bin/sh

set -e
ROOT=$(dirname "$0")/..

echo "=> Cleaning @ $(date)"
git clean -fdx
git submodule update --init

echo "=> Building @ $(date)"
cd $ROOT

make test && ./brubeck_test


## BOOTSTRAP

### https://github.com/octokit/octokit.rb/blob/master/script/bootstrap

#!/bin/sh

set -e

bundle install --quiet "$@"

### https://github.com/holman/dotfiles/blob/master/script/bootstrap

#!/usr/bin/env bash
#
# bootstrap installs things.

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

set -e

echo ''

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

setup_gitconfig () {
  if ! [ -f git/gitconfig.local.symlink ]
  then
    info 'setup gitconfig'

    git_credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      git_credential='osxkeychain'
    fi

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/gitconfig.local.symlink.example > git/gitconfig.local.symlink

    success 'gitconfig'
  fi
}


link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

setup_gitconfig
install_dotfiles

# If we're on a Mac, let's install and setup homebrew.
if [ "$(uname -s)" == "Darwin" ]
then
  info "installing dependencies"
  if source bin/dot > /tmp/dotfiles-dot 2>&1
  then
    success "dependencies installed"
  else
    fail "error installing dependencies"
  fi
fi

echo ''
echo '  All installed!'

### https://github.com/github-archive/swordfish/blob/master/script/bootstrap

#!/bin/sh
# Make sure all our deps exist.

# Export CC to explicitly set the compiler used for cexts.

export CC=cc

# Generate .bundle/config instead of using env vars or command line
# flags so that we have consistent configuration for our `bundle
# check` and `bundle install` calls here, as well as any manual calls
# to `bundle` that people might make.

# We don't want old config hanging around right now. This is sorta
# jank: We can do better.

rm -rf .bundle
mkdir .bundle

echo "---
BUNDLE_BIN: bin
BUNDLE_DISABLE_SHARED_GEMS: "1"
BUNDLE_PATH: vendor/gems
BUNDLE_WITHOUT: staging:production
" > .bundle/config

# Bundle install unless we're already up to date.

bundle check > /dev/null 2>&1 || bundle install "$@"

### https://github.com/github/hub/blob/master/script/bootstrap

#!/usr/bin/env bash
set -e

if [ -n "$TRAVIS" ]; then
  case "$TRAVIS_OS_NAME" in
    linux ) cache_name="tmux-zsh.ubuntu" ;;
    osx ) cache_name="tmux.osx" ;;
    * )
      echo "unknown OS: $TRAVIS_OS_NAME" >&2
      exit 1
      ;;
  esac

  curl -fsSL "https://${AMAZON_S3_BUCKET}.s3.amazonaws.com/${cache_name}.tgz" | tar -xz -C ~
  exit 0
fi

STATUS=0

if ! go version; then
  echo "You need to install Go 1.5.3 or higher to build hub" >&2
  STATUS=1
fi

{ ruby --version
  bundle install --path vendor/bundle
  bundle binstub cucumber ronn
} || {
  echo "You need Ruby 1.9 or higher and Bundler to run hub tests" >&2
  STATUS=1
}

if [ $STATUS -eq 0 ]; then
  echo "Everything OK."
fi

exit $STATUS



### https://github.com/github/github-services/blob/master/script/bootstrap

#!/bin/sh
# Usage: script/bootstrap
# Ensures all gems are in vendor/cache and installed locally.
set -e

if [ "$(uname -s)" = "Darwin" ]; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  bundle config --local build.eventmachine "--with-cppflags=-I$HOMEBREW_PREFIX/opt/openssl/include"
fi

bundle install --binstubs --local --path=vendor/gems
bundle package --all


### brubeck script/bootstrap

#!/bin/sh

ROOT=$(dirname "$0")/..
cd "$ROOT" && git submodule update --init && make brubeck

### https://github.com/github/gemoji/blob/master/script/bootstrap

#!/bin/bash
set -e

if type -p bundle >/dev/null; then
  bundle install --path vendor/bundle
  bundle binstub rake
else
  echo "You must \`gem install bundler\` first." >&2
  exit 1
fi

### https://github.com/github/choosealicense.com/blob/gh-pages/script/bootstrap

#!/bin/sh

set -e

echo "bundling installin'"
gem install bundler
bundle install

echo
echo "You're all set. Just run script/server and you can play license roulette!"

https://github.com/github/choosealicense.com/blob/gh-pages/script/check-approval

#!/usr/bin/env ruby
# Checks if a given license meets the approval criteria to be added to choosealicense.com
# See https://github.com/github/choosealicense.com/blob/gh-pages/CONTRIBUTING.md#adding-a-license
# Usage: script/check-approval [SPDX LICENSE ID]

require_relative '../spec/spec_helper'
require 'terminal-table'
require 'colored'
require 'fuzzy_match'

# Display usage instructions
if ARGV.count != 1
  puts File.open(__FILE__).read.scan(/^# .*/)[0...3].join("\n").gsub(/^# /, '')
end

class TrueClass
  def to_s
    'Yes'.green
  end
end

class FalseClass
  def to_s
    'No'.red
  end
end

license = ARGV[0].downcase.strip
approvals = {
  'OSI' => osi_approved_licenses,
  'FSF' => fsf_approved_licenses,
  'OD' => od_approved_licenses
}

id, spdx = find_spdx(license)
rows = []

if spdx.nil?
  id = 'Invalid'.red
  name = 'None'.red
else
  id = id.green
  name = spdx['name'].green
end

rows << ['SPDX ID', id]
rows << ['SPDX Name', name]

approvals.each do |approver, licenses|
  rows << ["#{approver} approved", licenses.include?(license)]
end

current = license_ids.include?(license)
rows << ['Current license', current]

rows << :separator
eligible = (!current && spdx && approved_licenses.include?(license))
rows << ['Eligible', eligible]

puts Terminal::Table.new title: "License: #{license}", rows: rows
puts
puts "Code search: https://github.com/search?q=#{license}+filename%3ALICENSE&type=Code"

if spdx.nil?
  puts
  puts 'SPDX ID not found. Some possible matches:'
  puts

  fm = FuzzyMatch.new(spdx_ids)
  matches = fm.find_all_with_score(license)
  matches = matches[0...5].map { |record, _dice, _levin| record }
  matches.each { |l| puts "* #{l}" }
end


https://github.com/github/choosealicense.com/blob/gh-pages/script/cibuild

#!/bin/sh

set -e

echo "building the site..."
bundle exec rake test
bundle exec rubocop -D -S


https://github.com/github/choosealicense.com/blob/gh-pages/script/downcase

#! /usr/bin/env ruby
# downcases all licenses in a git-friendly way

Dir['_licenses/*'].each do |file|
  system "git mv #{file} #{file.downcase}2"
  system "git mv #{file.downcase}2 #{file.downcase}"
end

https://github.com/github/choosealicense.com/blob/gh-pages/script/generate-docs

#!/usr/bin/env ruby
# Usage: script/generate-docs
# Reads in the fields, meta, and rules YAML files and produces markdown output
# suitable for documenting in the project's README

require 'yaml'

fields = YAML.load_file('_data/fields.yml')
meta   = YAML.load_file('_data/meta.yml')
rules  = YAML.load_file('_data/rules.yml')

puts "\n### Fields\n\n"
fields.each do |field|
  puts "* `#{field['name']}` - #{field['description']}"
end

puts "\n### YAML front matter\n"
meta = meta.group_by { |m| m['required'] }

puts "\n#### Required fields\n\n"
meta[true].each do |field|
  puts "* `#{field['name']}` - #{field['description']}"
end

puts "\n#### Optional fields\n\n"
meta[false].each do |field|
  puts "* `#{field['name']}` - #{field['description']}"
end

puts "\n### Rules\n"
rules.each do |group, group_rules|
  puts "\n#### #{group.capitalize}\n\n"
  group_rules.each do |rule|
    puts "* `#{rule['tag']}` - #{rule['description']}"
  end
end

https://github.com/github/choosealicense.com/blob/gh-pages/script/server


#!/bin/sh

set -e

echo "spinning up the server..."
bundle exec jekyll serve --watch --incremental --trace

echo "cleaning up..."
rm -Rf _site

https://github.com/github/gemoji/blob/master/script/regenerate

#!/bin/bash
# Usage: script/regenerate
#
# Note: only usable on OS X
#
# Combines `rake db:dump` and `db/aliases.html` filter to regenerate the
# `db/emoji.json` file using only emoji that are guaranteed to not render as
# ordinary characters on OS X.

set -e

case "$1" in
-h | --help )
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit 0
  ;;
esac

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Error: this script must be run under Mac OS X." >&2
  exit 1
fi

bundle exec rake db:dump > db/emoji2.json
mv db/emoji2.json db/emoji.json

open -g -a Safari db/aliases.html
osascript db/aliases.applescript | sed '/^$/d' > db/emoji2.json
mv db/emoji2.json db/emoji.json

if git diff --exit-code --stat -- db/emoji.json; then
  echo "Done. The file \`db/emoji.json\` remains unchanged."
fi

## GUARD

### https://github.com/octokit/octokit.rb/blob/master/script/guard

#!/bin/sh

set -e
script/bootstrap
bundle exec guard "$@"


## CONSOLE

### https://github.com/octokit/octokit.rb/blob/master/script/console

#!/bin/sh

set -e

dir=`pwd`

echo "===> Bundling..."
script/bootstrap --quiet

echo "===> Launching..."
bundle console

## https://github.com/github/github-services/blob/master/script/console


#!/bin/sh
# Usage: script/console
# Starts an IRB console with this library loaded.

exec bundle exec irb -r ./config/console

### config/console
require File.expand_path("../load", __FILE__)
Service.load_services

### config/load


require 'rubygems'
require 'bundler/setup'
$:.unshift *Dir["#{File.dirname(__FILE__)}/../vendor/internal-gems/**/lib"]

require File.expand_path("../../lib/github-services", __FILE__)

    def load_services
      require File.expand_path("../services/http_post", __FILE__)
      path = File.expand_path("../services/**/*.rb", __FILE__)
      Dir[path].each { |lib| require(lib) }
    end


### https://github.com/github/gemoji/blob/master/script/console

#!/bin/bash
set -e

public_methods() {
  sed '/^ *private/,$d' "$1" | grep -w def | sed -E 's/^ *def /  /; s/).+/)/'
}

echo "Emoji methods:"
public_methods lib/emoji.rb
echo
echo "Emoji::Character methods:"
public_methods lib/emoji/character.rb
echo

exec irb -I lib -r emoji

## RELEASE

### https://github.com/octokit/octokit.rb/blob/master/script/release

#!/usr/bin/env bash
# Usage: script/release
# Build the package, tag a commit, push it to origin, and then release the
# package publicly.

set -e

version="$(script/package | grep Version: | awk '{print $2}')"
[ -n "$version" ] || exit 1

echo $version
git commit --allow-empty -a -m "Release $version"
git tag "v$version"
git push origin
git push origin "v$version"
gem push pkg/*-${version}.gem

### https://github.com/github/gemoji/blob/master/script/release

#!/bin/bash
# Usage: script/release
#
# 1. Checks if tests pass,
# 2. commits gemspec,
# 3. tags the release with the version in the gemspec,
# 4. pushes "gemoji" gem to RubyGems.org.

set -e

case "$1" in
-h | --help )
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit 0
  ;;
esac

if git diff --quiet gemoji.gemspec; then
  echo "You must bump the version in the gemspec first." >&2
  exit 1
fi

script/test

trap 'rm *.gem' EXIT

version="$(gem build gemoji.gemspec | awk '/Version:/ { print $2 }')"
git commit gemoji.gemspec Gemfile.lock -m "gemoji $version"
git tag "v${version}"
git push origin HEAD "v${version}"
gem push "gemoji-${version}.gem"

## TEST

### https://github.com/octokit/octokit.rb/blob/master/script/test

#!/usr/bin/env bash

set -e

echo "===> Bundling..."
script/bootstrap --quiet

for testvar in LOGIN PASSWORD TOKEN CLIENT_ID CLIENT_SECRET
do
  octokitvar="OCTOKIT_TEST_GITHUB_${testvar}"
  if [[ -z "${!octokitvar}" ]]; then
      echo "Please export ${octokitvar}";
  fi
done

echo "===> Running specs..."
(unset OCTOKIT_LOGIN; unset OCTOKIT_ACCESS_TOKEN; bundle exec rake spec)

### https://github.com/github/hub/blob/master/script/test

#!/usr/bin/env bash
# Usage: script/test
#
# Run Go and Cucumber test suites for hub.

set -e

case "$1" in
"" )
  ;;
-h | --help )
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit
  ;;
* )
  "$0" --help >&2
  exit 1
esac

STATUS=0

trap "exit 1" INT

script/build
script/build test || STATUS="$?"
script/ruby-test || STATUS="$?"

exit "$STATUS"



### https://github.com/github/gemoji/blob/master/script/test

#!/bin/bash
# Usage: script/test [file]
set -e

case "$1" in
-h | --help )
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit 0
  ;;
esac

export RUBYOPT="$RUBYOPT -w"

exec bundle exec rake ${1:+TEST="$1"}

### https://github.com/github/github-services/blob/master/script/test


#!/bin/sh
# Usage: script/test
# Runs the library's test suite.

bundle exec rake test

## PACKAGE

### https://github.com/github/github-services/blob/master/script/package

#!/usr/bin/env bash
# Usage: script/package
# Updates the gemspec and builds a new gem in the pkg directory.

mkdir -p pkg
gem build *.gemspec
mv *.gem pkg

## VERSION

### https://github.com/github/hub/blob/master/script/version

#!/usr/bin/env bash
# Displays hub's release version
set -e

version="$(git describe --tags HEAD 2>/dev/null || true)"

if [ -z "$version" ]; then
  version="$(grep Version version/version.go | head -1 | cut -d '"' -f2)"
  sha="$(git rev-parse --short HEAD 2>/dev/null || true)"
  [ -z "$sha" ] || version="${version}-g${sha}"
fi

echo "${version#v}"


## CHANGELOG

### https://github.com/github/hub/blob/master/script/changelog

#!/bin/bash
# vi:ft=sh:
# Usage: script/changelog [HEAD]
#
# Show changes to runtime files between HEAD and previous release tag.
set -e

head="${1:-HEAD}"

for sha in `git rev-list -n 100 --first-parent "$head"^`; do
  previous_tag="$(git tag -l --points-at "$sha" 'v*' 2>/dev/null || true)"
  [ -z "$previous_tag" ] || break
done

if [ -z "$previous_tag" ]; then
  echo "Couldn't detect previous version tag" >&2
  exit 1
fi

git log --no-merges --format='%C(auto,green)* %s%C(auto,reset)%n%w(0,2,2)%+b' \
  --reverse "${previous_tag}..${head}" -- `script/build files`

## PACKAGE

### https://github.com/github/hub/blob/master/script/package

#!/usr/bin/env bash
# Usage: script/package <os> <arch> <version>
#
# Packages the project as a release asset and prints the archive's filename.
set -e

os="${1?}"
arch="${2?}"
version="${3?}"

release="hub-${os}-${arch}-${version}"

case "$os" in
  darwin | freebsd | linux | netbsd | openbsd | solaris | windows ) ;;
  * ) echo "unsupported OS: $os" >&2; exit 1 ;;
esac

case "$arch" in
  386 | amd64 | arm | arm64 ) ;;
  * ) echo "unsupported arch: $arch" >&2; exit 1 ;;
esac

export GOOS="$os"
export GOARCH="$arch"

tmpdir="tmp/${release}"
rm -rf "$tmpdir"

exename="${tmpdir}/bin/hub"
[ "$os" != "windows" ] || exename="${exename}.exe"
mkdir -p "${exename%/*}"
script/build -o "$exename"

crlf() {
  sed $'s/$/\r/' "$1" > "$2"
}

if [ "$os" = "windows" ]; then
  crlf README.md "${tmpdir}/README.txt"
  crlf LICENSE "${tmpdir}/LICENSE.txt"
  crlf man/hub.1.html "${tmpdir}/hub.html"
  crlf script/install.bat "${tmpdir}/install.bat"
else
  cp -R README.md LICENSE etc "$tmpdir"
  mkdir -p "${tmpdir}/share/man/man1"
  cp man/*.1 man/*.1.txt "${tmpdir}/share/man/man1"
  cp script/install.sh "${tmpdir}/install"
  chmod +x "${tmpdir}/install"
fi

if [ "$os" = "windows" ]; then
  file="${PWD}/${tmpdir}.zip"
  rm -f "$file"
  pushd "$tmpdir" >/dev/null
  zip -r "$file" * >/dev/null
else
  file="${PWD}/${tmpdir}.tgz"
  rm -f "$file"
  pushd "${tmpdir%/*}" >/dev/null
  tar -czf "$file" "$release"
fi

echo "$file"


### CROSS-COMPILE

#### https://github.com/github/hub/blob/master/script/cross-compile

#!/usr/bin/env bash
# Usage: script/cross-compile <version>
#
# Packages the project over a matrix of supported OS and architectures and
# prints the asset filenames and labels suitable for upload.
set -e

version="${1?}"

echo '
  darwin   amd64    OS X
  freebsd  386      FreeBSD 32-bit
  freebsd  amd64    FreeBSD 64-bit
  linux    386      Linux 32-bit
  linux    amd64    Linux 64-bit
  linux    arm      Linux ARM 32-bit
  linux    arm64    Linux ARM 64-bit
  windows  386      Windows 32-bit
  windows  amd64    Windows 64-bit
' | {
  while read os arch label; do
    [ -n "$os" ] || continue

    label="hub ${version} for ${label}"
    if ! file="$(script/package "$os" "$arch" "$version")"; then
      echo "packaging $label failed" >&2
      continue
    fi

    printf "%s\t%s\n" "$file" "$label"
  done
}

## CTAGS

### https://github.com/github/hub/blob/master/script/ctags

#!/bin/bash
# Usage: script/ctags [<tags-file=.git/tags>]
#
# Generates tags for Go runtime files. Requires universal-ctags.

set -e

case "$1" in
-h | --help )
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit 0
  ;;
esac

ctags -R --tag-relative -f "${1:-.git/tags}" \
  --exclude=etc \
  --exclude=script \
  --exclude=tmp \
  --exclude=vendor \
  --exclude='*_test.go' \
  .

## FORMAT-RONN

### https://github.com/github/hub/blob/master/script/format-ronn

#!/bin/bash
# Usage: script/format-ronn <COMMAND> [<FILE>]
#
# Transform inline text of hub commands to ronn-format(7).
set -e

AWK="$(type -p gawk awk | head -1)"

para() {
  "$AWK" -v wants=$2 "
    BEGIN { para=1 }
    /^\$/ { para++ }
    { if (para $1 wants) print \$0 }
  "
}

trim() {
  sed 's/^ \{1,\}//; s/ \{1,\}$//'
}

format_shortdesc() {
  tr $'\n' " " | trim
}

format_synopsis() {
  local cmd subcmd rest
  sed 's/^Usage://' | while read -r cmd subcmd rest; do
    printf '`%s %s` %s  \n' "$cmd" "$subcmd" "$rest"
  done
}

format_rest() {
  "$AWK" '
    /^#/ {
      title=toupper(substr($0, length($1) + 2, length($0)))
      sub(/:$/, "", title)
      options=title == "OPTIONS"
      print $1, title
      next
    }
    options && /^  [^ ]/ {
      printf "  * %s:\n", substr($0, 3, length($0))
      next
    }
    { print $0 }
  '
}

cmd="${1?}"
file="$2"
text="$(cat - | sed $'s/\t/  /g')"
[ -n "$text" ] || exit 1
[ -z "$file" ] || exec 1<> "$file"

echo "${cmd}(1) -- $(para == 2 <<<"$text" | format_shortdesc)"
echo "==="
echo
echo "## SYNOPSIS"
echo
para == 1 <<<"$text" | format_synopsis
echo
para '>=' 3 <<<"$text" | format_rest

## INSTALL

### https://github.com/holman/dotfiles/blob/master/script/install

#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

cd "$(dirname $0)"/..

# Run Homebrew through the Brewfile
echo "› brew bundle"
brew bundle

# find the installers and run them iteratively
find . -name install.sh | while read installer ; do sh -c "${installer}" ; done


### https://github.com/github/hub/blob/master/script/install.sh

#!/usr/bin/env bash
# Usage: [sudo] [prefix=/usr/local] ./install
set -e

case "$1" in
'-h' | '--help' )
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit 0
  ;;
esac

if [[ $BASH_SOURCE == */* ]]; then
  cd "${BASH_SOURCE%/*}"
fi

prefix="${PREFIX:-$prefix}"
prefix="${prefix:-/usr/local}"

for src in `find bin share -type f`; do
  dest="${prefix}/${src}"
  mkdir -p "${dest%/*}"
  install "$src" "$dest"
done

## RUBY-TEST

### https://github.com/github/hub/blob/master/script/ruby-test

#!/usr/bin/env bash
set -e

STATUS=0
warnings="${TMPDIR:-/tmp}/gh-warnings.$$"

run() {
  # Save warnings on stderr to a separate file
  RUBYOPT="$RUBYOPT -w" bundle exec "$@" \
    2> >(tee >(grep 'warning:' >>"$warnings") | grep -v 'warning:') || STATUS=$?
}

check_warnings() {
  # Display Ruby warnings from this project's source files. Abort if any were found.
  num="$(grep -F "$PWD" "$warnings" | grep -v "${PWD}/vendor/bundle" | sort | uniq -c | sort -rn | tee /dev/stderr | wc -l)"
  rm -f "$warnings"
  if [ "$num" -gt 0 ]; then
    echo "FAILED: this test suite doesn't tolerate Ruby syntax warnings!" >&2
    exit 1
  fi
}

if tmux -V; then
  if [ -n "$CI" ]; then
    git --version
    bash --version | head -1
    zsh --version
    echo
  fi
  profile="all"
else
  echo "warning: skipping shell completion tests (install tmux to enable)" >&2
  profile="default"
fi

run cucumber -p "$profile"
check_warnings

exit $STATUS

## S3-PUT

### https://github.com/github/hub/blob/master/script/s3-put

#!/usr/bin/env bash
# Usage: s3-put <FILE> <S3_BUCKET>[:<PATH>] [<CONTENT_TYPE>]
#
# Uploads a file to the Amazon S3 service.
# Outputs the URL for the newly uploaded file.
#
# Requirements:
# - AMAZON_ACCESS_KEY_ID
# - AMAZON_SECRET_ACCESS_KEY
# - openssl
# - curl
#
# Author: Mislav Marohnić

set -e

authorization() {
  local signature="$(string_to_sign | hmac_sha1 | base64)"
  echo "AWS ${AMAZON_ACCESS_KEY_ID?}:${signature}"
}

hmac_sha1() {
  openssl dgst -binary -sha1 -hmac "${AMAZON_SECRET_ACCESS_KEY?}"
}

base64() {
  openssl enc -base64
}

bin_md5() {
  openssl dgst -binary -md5
}

string_to_sign() {
  echo "$http_method"
  echo "$content_md5"
  echo "$content_type"
  echo "$date"
  echo "x-amz-acl:$acl"
  printf "/$bucket/$remote_path"
}

date_string() {
  LC_TIME=C date "+%a, %d %h %Y %T %z"
}

file="$1"
bucket="${2%%:*}"
remote_path="${2#*:}"
content_type="$3"

if [ -z "$remote_path" ] || [ "$remote_path" = "$bucket" ]; then
  remote_path="${file##*/}"
fi

http_method=PUT
acl="public-read"
content_md5="$(bin_md5 < "$file" | base64)"
date="$(date_string)"

url="https://$bucket.s3.amazonaws.com/$remote_path"

curl -qsSf -T "$file" \
  -H "Authorization: $(authorization)" \
  -H "x-amz-acl: $acl" \
  -H "Date: $date" \
  -H "Content-MD5: $content_md5" \
  -H "Content-Type: $content_type" \
  "$url"

echo "$url"

## GITHUB SAMPLES

### https://github.com/github/platform-samples/tree/master/api/ruby

  ..    
basics-of-authentication  Require bundler/setup 6 months ago
building-a-ci-server  Update all Gemfiles to use json 1.8+  3 months ago
delivering-deployments  Update all Gemfiles to use json 1.8+  3 months ago
discovering-resources-for-a-user  Add samples: Discover resources for the current user  a year ago
enterprise  Add comments  2 years ago
instance-auditing Use HTTPS (not HTTP) for api.github.com 8 months ago
rendering-data-as-graphs  Update all Gemfiles to use json 1.8+  3 months ago
traversing-with-pagination  Improve regex for octokit pagination examples 6 months ago
user-auditing Rename user audit to suspended user audit 9 months ago
working-with-comments Add the working-with-comments samples 3 years ago
2fa_checker.rb  Use HTTPS (not HTTP) for api.github.com 8 months ago
fork_checker.rb Add the fork_checker.rb 2 years ago
team_audit.rb Use HTTPS (not HTTP) for api.github.com 8 months ago
Status API Training Shop Blog About


### https://github.com/github/platform-samples/blob/master/api/bash/repo-list-export.sh

#!/usr/bin/env bash
#
# set GITHUB_TOKEN to your GitHub or GHE access token
# set GITHUB_API_ENDPOINT to your GHE API endpoint (defaults to https://api.github.com)

if [ -n "$GITHUB_API_ENDPOINT" ]; then
  url=$GITHUB_API_ENDPOINT
else
  url="https://api.github.com"
fi

token=$GITHUB_TOKEN

OUTPUT_FORMAT="list"

today=$(date +"%Y-%m-%d")

dependency_test()
{
  for dep in curl jq ; do
    command -v $dep &>/dev/null || { echo -e "\n${_error}Error:${_reset} I require the ${_command}$dep${_reset} command but it's not installed.\n"; exit 1; }
  done
}

token_test()
{
  if [ -n "$token" ]; then
    token_cmd="Authorization: token $token"
  else
    echo "You must set a Personal Access Token to the GITHUB_TOKEN environment variable"
    exit 1
  fi
}

usage()
{
  echo -e "Usage: $0 [options] <orgname>...\n"
  echo "Options:"
  echo " -h | --help              Display this help text"
  echo " -a | --array-format      Output the repository list in"
  echo "                          \"<orgname>/<repo1>\",\"<orgname>/<repo2>\" format"
  echo ""
}

# Progress indicator
working() {
   echo -n "."
}

work_done() {
  echo -n "done!"
  echo -e "\n"
}

output_list()
{
  if [[ "$OUTPUT_FORMAT" == "array" ]]; then
    printf '%s\n' "${all_repos[@]}" | sort --ignore-case | sed -E "s/^(.*)/\"$org\/\1\"/g" | paste -sd ',' - > $org-$today.txt
  else
    printf '%s\n' "${all_repos[@]}" | sort --ignore-case > $org-$today.txt
  fi
}

get_repos()
{
  last_repo_page=$( curl -s --head -H "$token_cmd" "$url/orgs/$org/repos?per_page=100" | sed -nE 's/^Link:.*per_page=100.page=([0-9]+)>; rel="last".*/\1/p' )

  if [[ "$last_repo_page" == "" ]]; then
    echo "Fetching repository list for '$org' organization"
    all_repos=($( curl -s -H "$token_cmd" "$url/orgs/$org/repos?per_page=100" | jq --raw-output '.[].name'  | tr '\n' ' ' ))
    output_list
    total_repos=$( echo "${all_repos[@]}" | wc -w | tr -d "[:space:]" )
    echo
    echo "Total # of repositories in "\'$org\'": $total_repos"
    echo "List saved to $org-$today.txt"
  else
    echo "Fetching repository list for '$org' organization"
    all_repos=()
    for (( i=1; i<=$last_repo_page; i++ ))
    do
      working
      paginated_repos=$( curl -s -H "$token_cmd" "$url/orgs/$org/repos?per_page=100&page=$i" | jq --raw-output '.[].name'  | tr '\n' ' ' )
      all_repos=(${all_repos[@]} $paginated_repos)
    done
    work_done
    output_list
    total_repos=$( echo "${all_repos[@]}" | wc -w | tr -d "[:space:]" )
    echo "Total # of repositories in "\'$org\'": $total_repos"
    echo "List saved to $org-$today.txt"
  fi
}

#### MAIN

dependency_test

token_test

if [[ -z "$*" ]] ; then
  echo "Error: no organization name entered" 1>&2
  echo
  usage
  exit 1
fi

while [[ "$1" != "" ]]; do
  case $1 in
    -h | --help )         usage
                          exit ;;
    -a | --array-format ) OUTPUT_FORMAT="array";;
    -* )                  echo "Error: invalid argument: '$1'" 1>&2
                          echo
                          usage
                          exit 1;;
    * )                   org="$1"
                          get_repos
  esac
  shift
done

exit 0


