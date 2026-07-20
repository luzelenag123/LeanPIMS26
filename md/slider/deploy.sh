#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"
DEST=../../docs

mkdir -p $DEST
mkdir -p $DEST/vendor
cp  *.html *.js *.css *.json $DEST
cp -r src $DEST

mkdir -p  $DEST/vendor/github-markdown-css
cp node_modules/github-markdown-css/github-markdown.css $DEST/vendor/github-markdown-css

mkdir -p  $DEST/vendor/js-cookie/
mkdir -p  $DEST/vendor/js-cookie/src/
cp node_modules/js-cookie/src/js.cookie.js $DEST/vendor/js-cookie/src

mkdir -p  $DEST/vendor/showdown
mkdir -p  $DEST/vendor/showdown/dist
cp node_modules/showdown/dist/showdown.min.js $DEST/vendor/showdown/dist

mkdir -p  $DEST/vendor/showdown-katex
mkdir -p  $DEST/vendor/showdown-katex/dist
cp node_modules/showdown-katex/dist/showdown-katex.min.js $DEST/vendor/showdown-katex/dist

mkdir -p  $DEST/vendor/react
mkdir -p  $DEST/vendor/react/umd
cp  node_modules/react/umd/react.production.min.js $DEST/vendor/react/umd

mkdir -p  $DEST/vendor/react-dom
mkdir -p  $DEST/vendor/react-dom/umd
cp node_modules/react-dom/umd/react-dom.production.min.js $DEST/vendor/react-dom/umd

cp -r img $DEST

touch $DEST/.nojekyll
