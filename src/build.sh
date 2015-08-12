#!/bin/bash

echo "Compiling coffee..."
coffee --join public/js/app.js --compile src/coffee/router src/coffee/models src/coffee/view src/coffee/App.coffee
echo "OK."

echo "Compiling sass..."
sass src/sass/style.scss public/css/main.css
echo "OK."

echo "Creating symlink..."
cd ./
# Remove any existing public folder (or symlink) in rails directory
rm -rf api/public
# Create symlink (currently in root repo dir)
ln -s ../public symlink
# Move symlink to right place
mv symlink api/
# Rename symlink to `public` now that it's inside the Rails app.
cd api
mv symlink public
echo "OK."

echo "DONE."