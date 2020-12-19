#!/usr/bin/env bash

www_directory=/var/www/html

# This follows Crypto++ release number
ref_dir=ref820/

if [[ ($(id -u) != "0") ]]; then
    echo "You must be root to update the docs"
    exit 1
fi

if [[ ! -f CryptoPPRef.zip ]]; then
    echo "CryptoPPRef.zip is missing"
    exit 1
fi

if [ ! -d "${www_directory}" ]; then
    echo "Unable to locate website directory"
    exit 1
fi

echo "Preparing files and directories"
mkdir -p "${www_directory}/docs"
mv CryptoPPRef.zip "${www_directory}/docs"
cd "${www_directory}/docs"

# Remove old link, add new link
rm -f ref
mkdir -p "${ref_dir}"
ln -s "${ref_dir}" ref

echo "Unpacking documentation"
unzip -aoq CryptoPPRef.zip -d .
mv CryptoPPRef.zip ref/

echo "Changing ownership"
chown -R root:apache "${www_directory}/docs"
chown root:apache ref/CryptoPPRef.zip

echo "Setting directory permissions"
IFS= find "${www_directory}/docs" -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "${dir}"
done

echo "Setting file permissions"
IFS= find "${www_directory}/docs" -type f -print | while read -r file
do
    if file -b "${file}" | grep -q -E 'executable|script';
    then
        chmod u=rwx,g=rx,o= "${file}"
    else
        chmod u=rw,g=r,o= "${file}"
    fi
done

echo "Restarting web server"
systemctl restart httpd24-httpd.service

exit 0
