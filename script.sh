#!/usr/bin/env bash

echo
echo "CA Certificate Signing Request and Private Key Creation Tool"
echo "v 1.0 [Initial dev: 2016.02.01] | Last update: 2016.06.20 | Published: 20171016]
echo "written by Nk [openspace]"
sleep 0.7

loc_certs_dir="/root/io/certs/"
loc_keys_dir="/root/io/keys/"
loc_csrs_dir="/root/io/csrs/"

echo
echo "First off enter the name for your new server in this format:"
echo "  One letter [x, y, or z] for the server location: x = local, y = remote, z = local machine [testing]"
echo "  One letter [x, y, or z] for the server type: x = physical, y = virtual, z = nested virtual [or other]"
echo "  Two letters for the description:"
echo "    If your new server is type x the OS [ub, db, cn, ...]"
echo "    If your new server is type y or z the main app / service / function it will serve [wp, nx, bn, ...]."
echo "  Two digits for sequential numbering in case there are other servers with the same name [check school server list for reference]."
echo "As such: xywp01   Only enter this. Do not enter the server's full hostname [xywp01.example.org]"
echo
read server_name

if test -f $loc_certs_dir$server_name.crt;

then	echo "A server with the same name already exists in the school and has a certificate registered here on the CA."
	echo "If you are recreating this certificate you may proceed by simply typing the name again right here:"
	echo "Otherwise please check the name you have typed and either type it again correctly if it was wrong or write a new one:"
	read server_name

fi

echo
echo "The local DNS server has this IP Address record for $server_name.example.org:"
echo
nslookup -querytype=a $server_name.example.org | grep Address | grep -v 53
echo
echo "If you need to change it enter it below. Otherwise if it's correct simply press return."
echo
read server_address

if [ "$server_address" = "" ];
then server_address=$server_name.example.org
fi

echo

echo "If you'd like to specify a location that differs from the standard [/etc/ssl/certs/] for certificates on your new server specify it below, otherwise simply press return to use the standard."
echo
read rem_certs_dir
if [ "$rem_certs_dir" = "" ];
then rem_certs_dir="/etc/ssl/certs/"
fi
echo

echo "If you'd like to specify a location that differs from the standard [/etc/ssl/private/] for private keys on your new server specify it below, otherwise simply press return to use the standard."
echo
read rem_keys_dir
if [ "$rem_keys_dir" = "" ];
then rem_keys_dir="/etc/ssl/private/"
fi
echo

echo "Now testing certificate directory existence on remote erver..."
echo
cat << EOF > /tmp/nk-ca-creator-tmp01.sh

if test ! -d $rem_certs_dir; then

	echo "No remote certificates directory found. Creating directory...";
	echo
	mkdir -p $rem_certs_dir
	chmod -R 755 $rem_certs_dir
	echo "Certificate directory structure created."
	echo
else
	echo "Certificate directory structure found.";
	echo
fi
exit

EOF

chmod +x /tmp/nk-ca-creator-tmp01.sh
sshpass ssh root@$server_address 'bash -s' < /tmp/nk-ca-creator-tmp01.sh

echo "Now testing private key directory existence on remote erver..."
echo
cat << EOF > /tmp/nk-ca-creator-tmp02.sh

if test ! -d $rem_keys_dir; then

        echo "No remote private key directory found. Creating directory...";
	echo
        mkdir -p $rem_keys_dir
        chmod -R 600 $rem_keys_dir
        echo "Private key directory structure created."
	echo

else
        echo "Private key directory structure found.";
	echo

fi
exit

EOF

chmod +x /tmp/nk-ca-creator-tmp02.sh
sshpass ssh root@$server_address 'bash -s' < /tmp/nk-ca-creator-tmp02.sh

echo
echo "Enter your school email address"
echo
read email_address

echo
echo "Enter the first of any functional example.org subdomains you'd like to register for this server in this format:"
echo "  Four letters for the description of the app / service / function it will serve: [wdps, ngnx, bind, ...]"
echo "As such: wdps.example.org. Enter the full subdomain [wdps.example.org]."
echo "If you want to add the top-level domain example.org you may do so here by typing example.org"
echo "If you don't want to add any subdomains, simply press return."
echo
read altname_one
echo

if [ "$altname_one" != "" ];

then	echo "If you have a second functional subdomain you'd like to add please do so now."
	echo "As such: wdps.example.org. Enter the full subdomain [wdps.example.org]."
	echo "If you don't want to add a second subdomain, simply press return."
	echo
	read altname_two
	echo

	if [ "$altname_two" != "" ];

	then	echo "If you have a third functional subdomain you'd like to add please do so now."
		echo "As such: wdps.example.org. Enter the full subdomain [wdps.example.org]."
        	echo "If you don't want to add a third subdomain, simply press return."
        	echo
        	read altname_three
        	echo

		if [ "$altname_three" != "" ];

		then openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout $loc_keys_dir$server_name.key -out $loc_csrs_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
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

		else openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout $loc_keys_dir$server_name.key -out $loc_csrs_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
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

	else openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout $loc_keys_dir$server_name.key -out $loc_csrs_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
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

else openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout $loc_keys_dir$server_name.key -out $loc_csrs_dir$server_name.csr -days 1460 -subj '/C=IT/ST=MI/L=Milano/O=Bilingual European School/OU=ICT Hacker Spaceship/CN='"$server_name"'.example.org/emailAddress='"$email_address" -config <(
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
echo "writing new csr to '$loc_csrs_dir$server_name.csr'"
echo -----
echo
echo "New csr and private key created."
echo
echo "Now you will be asked to enter the CA private key passphrase to authenticate the certificate signing procedure."
echo "After that make sure you review all of the certificate details before you confirm."
echo
openssl ca -extensions v3_req -out $loc_certs_dir$server_name.crt -infiles $loc_csrs_dir$server_name.csr
echo
echo "Now copying the signed certificate and private key to your new server..."
echo
scp $loc_certs_dir$server_name.crt root@$server_address:$rem_certs_dir
echo
scp $loc_keys_dir$server_name.key root@$server_address:$rem_keys_dir
echo
echo "Done! Now you're ready to configure your services to use the newly created certificate and private key!"
echo

rm /tmp/nk-ca-creator-tmp01.sh /tmp/nk-ca-creator-tmp02.sh
rm $loc_csrs_dir$server_name.csr $loc_certs_dir$server_name.crt $loc_keys_dir$server_name.key

echo "New certificate location on your new server: $rem_certs_dir$server_name.crt"
echo "New private key location on your new server: $rem_keys_dir$server_name.key"
echo
echo "Thanks! Bye!"
echo
exit
