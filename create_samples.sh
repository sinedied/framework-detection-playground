#!/bin/bash
#######################################
# Usage: ./create_samples.sh [--clean]
#######################################

CI=true

set -e
if [ ! -z "$DEBUG" ]; then
  echo "> Debug mode enabled <"
fi
if [ "$1" == "--clean" ]; then
  echo "Cleaning existing samples..."
  rm -rf samples
fi
mkdir -p samples/api samples/app

# gen <name> <command> [<create_dir>] [<dir_to_rename>]
gen() {
  name=$1
  cmd=$2
  mk_dir=$3
  rename_dir=$4
  if [ -d $name ]; then
    echo "Skipping $name (already exists)"
    return
  fi
  echo "Generating $name..."
  if [ "$mk_dir" == true ]; then
    mkdir $name
    pushd $name > /dev/null
  else
    pushd . > /dev/null
  fi
  if [ -z "$DEBUG" ]; then
    eval "$cmd" > /dev/null
  else
    eval "$cmd"
  fi
  popd > /dev/null
  if [ ! -z "$rename_dir" ]; then
    mv $rename_dir $name
  fi
}

# autoenter <command>
autoenter() {
  expect -c "
    set timeout -1
    spawn $*
    expect {
      -re \"\[?\]\" { send \"\r\"; exp_continue }
    }"
}

# nofail <command>
nofail() {
  eval "$1" || true
}

npx() {
  command npx -y "$@"
}
#######################################
# API frameworks (for Azure Functions)
#######################################
pushd samples/api > /dev/null
echo "=== Generating API samples ==="

gen dotnet "func init --worker-runtime dotnet" true
gen dotnet-isolated "func init --worker-runtime dotnetIsolated" true
gen dotnet-csx "func init --worker-runtime dotnet" true
gen python "func init --worker-runtime python" true
gen node "func init --worker-runtime node" true
gen node-ts "func init --worker-runtime node --language typescript" true

#######################################
# App frameworks
#######################################
popd > /dev/null
pushd samples/app > /dev/null
echo "=== Generating App samples ==="

gen static "echo '<!doctype html><html><body>Hello</body></html>' > index.html" true
gen angular "npx @angular/cli@latest new angular --defaults --skip-git --skip-install --minimal"
gen angular-scully "npx @angular/cli@latest new angular-scully --defaults --skip-git --skip-install --minimal && cd angular-scully && nofail \"npx @angular/cli@latest add --skip-confirmation --defaults @scullyio/init@latest\""
gen react "npx create-react-app@latest react-app" false react-app
gen preact "npx preact-cli@latest create default preact"
gen vue "npx create-vue@latest vue --default"
gen docusaurus "npx create-docusaurus@latest docusaurus classic --skip-install"
gen nuxtjs "npx create-nuxt-app@latest nuxtjs --answers '{\"name\":\"nuxt\",\"language\":\"ts\",\"pm\":\"npm\",\"ui\":\"none\",\"target\":\"static\",\"features\":[],\"linter\":[],\"test\":\"none\",\"mode\":\"universal\",\"devTools\":[]}'"
gen nextjs "npx create-next-app nextjs --use-npm"
gen vuepress "autoenter npx -y create-vuepress-site@latest vuepress"
gen aurelia "npx aurelia-cli@latest new aurelia --select"
gen gatsby "npx create-gatsby@latest -y gatsby"
gen svelte "npx degit sveltejs/template svelte"
gen ember "npx ember-cli@latest new ember-app --lang en --skip-git true --skip-npm true" false ember-app
gen riot "autoenter npx -y create-riot@latest riot" true
gen stencil "npx create-stencil@latest app stencil"
gen polymer "npx degit PolymerLabs/polymer-3-first-element polymer"
gen lit "npx @open-wc/create --type scaffold --scaffoldType app --typescript true --tagName lit-app --installDependencies false --features --writeToDisk true" false lit-app
gen marko "autoenter npx -y @marko/create@latest marko"
gen hexo "npx hexo-cli init hexo"
gen ionic-angular "autoenter npx -y @ionic/cli start ionic-angular blank --type angular --no-deps --no-git"
gen ionic-react "autoenter npx -y @ionic/cli start ionic-react blank --type react --no-deps --no-git"
gen ionic-vue "autoenter npx -y @ionic/cli start ionic-vue blank --type vue --no-deps --no-git"
gen capacitor "npx @capacitor/create-app capacitor --name capacitor --app-id com.fw.playground"
gen hugo "hugo new site hugo"
gen elm "yes | elm init" true
gen django "django-admin startproject djangoapp" false djangoapp
gen meteor "meteor create --blaze meteor --allow-superuser"
gen blazor "dotnet new blazorserver -o blazor --no-https"
gen flutter "flutter create flutterapp" false flutterapp
