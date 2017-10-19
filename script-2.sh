#!/usr/bin/env bash

echo
echo "CA Certificate Signing Request and Private Key Creation Tool"
echo "v 1.0 [Initial dev: 2016.02.01] | Last update: 2016.06.20 | Published: 20171016]
echo "written by Nk [openspace]"
sleep 0.7
echo
echo "Testing /etc/ssl/ directory existence..."

if test ! -d /etc/ssl/certs/; then

	echo "No /etc/ssl/ directory found... Creating directory structure...";
	mkdir -p /etc/ssl/certs/ /etc/ssl/private/
	cd /etc/ssl/
	chmod -R 755 certs/
	chmod -R 600 private/
	echo "Directory structure created."

else

	cd /etc/ssl/
	echo "Directory structure found.";

fi

certs_dir="/etc/ssl/certs/"
pkey_dir="/etc/ssl/private/"
csr_dir="/etc/ssl/"

echo
echo "Enter your school email address"
echo
read email_address

echo
echo "Please enter the name for your new server in this format:"
echo "  One letter [x, y, or z] for the server location: x = local, y = remote, z = local machine [testing]"
echo "  One letter [x, y, or z] for the server type: x = physical, y = virtual, z = nested virtual [or other]"
echo "  Two letters for the description:"
echo "    If your new server is type x the OS [ub, db, cn, ...]"
echo "    If your new server is type y or z the main app / service / function it will serve [wp, nx, bn, ...]."
echo "  Two digits for sequential numbering in case there are other servers with the same name [check school server list for reference]."
echo "As such: xywp01   Only enter this. Do not enter the server's full hostname [xywp01.example.org]"
echo
read server_name
echo
echo "Enter the first of any functional example.org subdomains you'd like to register for this server in this format:"
echo "  Four letters for the description of the app / service / function it will serve: [wdps, ngnx, bind, ...]"
echo "As such: wdps   Only enter this. Do not enter the full subdomain [wdps.example.org]."
echo "If you don't want to add any subdomains, simply press return."
echo
read altname_one
echo

if [ "$altname_one" != "" ];

then	altname_one="$altname_one".example.org
	echo "If you have a second functional subdomain you'd like to add please do so now."
	echo "As such: wdps   Only enter this. Do not enter the full subdomain [wdps.example.org]."
	echo "If you don't want to add a second subdomain, simply press return."
	echo
	read altname_two
	echo

	if [ "$altname_two" != "" ];

	then	altname_two="$altname_two".example.org
		echo "If you have a second functional subdomain you'd like to add please do so now."
        	echo "As such: wdps   Only enter this. Do not enter the full subdomain [wdps.example.org]."
        	echo "If you don't want to add a third subdomain, simply press return."
        	echo
        	read altname_three
        	echo

		if [ "$altname_three" != "" ];

		then altname_three="$altname_three".example.org
openssl req -new -newkey rsa:4096 -nodes -sha256  -keyout $pkey_dir$server_name.key -out $csr_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
cat <<-EOF
[req]
default_bits = 4096
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = "$server_name".example.org
DNS.2 = "$altname_one"
DNS.3 = "$altname_two"
DNS.4 = "$altname_three"
EOF
)

		else openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout $pkey_dir$server_name.key -out $csr_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
cat <<-EOF
[req]
default_bits = 4096
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = "$server_name".example.org
DNS.2 = "$altname_one"
DNS.3 = "$altname_two"
EOF
)

		fi

	else openssl req -new -newkey rsa:4096 -nodes -sha256  -keyout $pkey_dir$server_name.key -out $csr_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
cat <<-EOF
[req]
default_bits = 4096
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = "$server_name".example.org
DNS.2 = "$altname_one"
EOF
)


	fi

else openssl req -new -newkey rsa:4096 -nodes -sha256  -keyout $pkey_dir$server_name.key -out $csr_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
cat <<-EOF
[req]
default_bits = 4096
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = "$server_name".example.org
EOF
)

fi

echo
echo "writing new csr to '$csr_dir$server_name.csr'"
echo -----
echo
echo "Now copying csr to CA server..."
echo
scp $csr_dir$server_name.csr root@192.168.1.113:/root/scp/
echo
echo "Now you will be asked to enter the CA private key passphrase to authenticate the certificate signing procedure."
echo "After that make sure you review all of the certificate details before you confirm."
echo
ssh root@192.168.1.113 openssl ca -extensions v3_req -out ~/done/$server_name.crt -infiles ~/scp/$server_name.csr
echo
echo "Now copying the signed certificate back to this server..."
echo
scp root@192.168.1.113:/root/done/$server_name.crt  /etc/ssl/certs/
echo
echo "Done! Now you're ready to configure your services to use the newly created certificate and private key!"
echo
echo "New certificate location: $certs_dir$server_name.crt"
echo "New private key location: $pkey_dir$server_name.crt"
echo
echo "Thanks! Bye!"
exit
