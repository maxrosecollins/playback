echo "Compiling coffee..."
call coffee --join public/js/app.js --compile src/coffee/router src/coffee/models src/coffee/view src/coffee/App.coffee
echo "OK."

echo "Compiling sass..."
call sass src/sass/style.scss public/css/main.css
echo "OK."

echo "Creating symlink..."
echo "Remove any existing public folder (or symlink) in rails directory"
rmdir %CD%\api\public
echo "Creating symlink(junction)..."
mklink /j %CD%\api\public %CD%\public
echo "OK."