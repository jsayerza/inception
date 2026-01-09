#!/bin/bash

echo "Starting FTP setup..."

# Create FTP user, if it doesn't exist
if ! id -u ${FTP_USER} > /dev/null 2>&1; then
	echo "Creating FTP user: ${FTP_USER}"

	# Access user to WP dir
	useradd --home /var/www/html --no-create-home ${FTP_USER}

	# Set pwd
	echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

	echo "FTP user created successfully"
else
	echo "FTP user already exists"
fi

# Grant permissions
chown -R ${FTP_USER}:${FTP_USER} /var/www/html 2>/dev/null || true
chmod -R 755 /var/www/html

# Create PAM file config if it doesn't exist
if [ ! -f /etc/pam.d/vsftpd ]; then
	echo "auth required pam_unix.so" > /etc/pam.d/vsftpd
	echo "account required pam_unix.so" >> /etc/pam.d/vsftpd
fi

# Create secure chroot directory (required by vsftpd)
mkdir -p /var/run/vsftpd/empty
chown root:root /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

# Start vsftpd in foreground
echo "Starting vsftpd in foreground..."
#exec /usr/sbin/vsftpd -o background=NO /etc/vsftpd.conf 
exec /usr/sbin/vsftpd /etc/vsftpd.conf 

