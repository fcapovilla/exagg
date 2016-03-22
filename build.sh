#!/bin/sh

rm -rf priv/static/*
rm -rf web/templates/page/index.html.eex

cd client
ember build -prod -o ../priv/static/
cd ..

mv priv/static/index.html web/templates/page/index.html.eex

MIX_ENV=prod mix compile
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release
