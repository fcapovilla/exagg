#!/bin/sh

rm -rf priv/static/*
rm -rf web/templates/page/index.html.eex

cd client
ember build -prod -o ../priv/static/
cd ..

mv priv/static/index.html web/templates/page/index.html.eex

mix compile
mix phoenix.digest
