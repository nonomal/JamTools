original_dir=$(dirname "$(readlink -f "$0")")
echo "Original directory: $original_dir"
echo "Building JamTools executable..."
cd ${original_dir}
cd ../../ && pyinstaller installer.spec  -y 
cd ${original_dir}

echo "Building JamTools DEB package..."
rm -rf package
mkdir -p package/opt
mkdir -p package/usr/share/applications
mkdir -p package/usr/share/icons/hicolor/scalable/apps

echo "Copying files to package directory..."
cp -r ../../dist/JamTools package/opt/JamTools
cp ../../icon.png package/usr/share/icons/hicolor/scalable/apps/icon.png
cp JamTools.desktop package/usr/share/applications

# 检查并处理Python库文件
echo "Checking Python library files..."
JAMTOOLS_LIB_DIR="package/opt/JamTools/_internal"
if [ ! -f "$JAMTOOLS_LIB_DIR/libpython3.8.so" ] && [ -f "$JAMTOOLS_LIB_DIR/libpython3.8.so.1.0" ]; then
    echo "Creating symlink for Python library..."
    cd "$JAMTOOLS_LIB_DIR"
    cp libpython3.8.so.1.0 libpython3.8.so
    cd "${original_dir}"
fi

echo "Setting permissions..."
chmod +x package/opt/JamTools/JamTools

echo "Building DEB package..."


version=$(grep -m 1 'VERSON' ../../installer.spec | cut -d'"' -f2)
file="jamtools_${version}_amd64.deb"
if [ -f "$file" ]; then
    rm "$file"
    echo "File $file is deleted."
fi
echo "Version: $version"
fpm -C package -s dir -t deb -n "jamtools" -v "${version}" -p "$file"
echo "Done!"
