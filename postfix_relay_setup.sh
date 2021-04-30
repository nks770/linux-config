#!/bin/bash

# Adapted in part from this resource:
# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/postfix.html

# Default Settings
smtp=email-smtp.us-west-2.amazonaws.com
port=587

# Configure to and from email addresses
echo
echo '#####################################'
echo '## DEFAULT TO/FROM EMAIL ADDRESSES ##'
echo '#####################################'
if [ -f ~/.email ] ; then
  email=$(cat ~/.email)
fi
if [ -f ~/.email ] ; then
  emailfrom=$(cat ~/.emailfrom)
fi
echo
echo -n "Default address to send email TO [${email}] ="
read k
if [ ! -z "${k}" ] ; then
   email=${k}
fi
echo -n "Email address to send email FROM [${emailfrom}] ="
read k
if [ ! -z "${k}" ] ; then
   emailfrom=${k}
fi
echo

# Get SMTP relay server address and port
echo
echo '##################################'
echo '## SMTP MAIL RELAY SERVER SETUP ##'
echo '##################################'
echo
echo -n "Outbound SMTP relay server [${smtp}] ="
read k
if [ ! -z "${k}" ] ; then
   smtp=${k}
fi
echo -n "Outbound SMTP relay server port [${port}] ="
read k
if [ ! -z "${k}" ] ; then
   port=${k}
fi
echo
echo Configured outbound SMTP server ${smtp}:${port}
echo

# Search for credentials file
if [ -f ~/credentials.csv ] ; then
  echo 'Found credentials file ~/credentials.csv, importing...'
  a=$(sed -n 2p ~/credentials.csv)
  b=${a#*,}
  user=${b%,*}
  pass=${b#*,}
else
  user=username
  pass=password
fi

# Get or confirm credentials
echo
echo '#############################################'
echo '## ENTER CREDENTIALS FOR MAIL RELAY SERVER ##'
echo '#############################################'
echo
echo -n "Username [${user}]= "
read k
if [ ! -z "${k}" ] ; then
   user=${k}
fi
echo -n "Password [${pass}]= "
read k
if [ ! -z "${k}" ] ; then
   pass=${k}
fi

echo
echo '########################'
echo '## TRANSPORT SETTINGS ##'
echo '########################'
tselect=0
while [ "${tselect}" != "1" ] && [ "${tselect}" != "2" ] ; do
echo
echo '(1) Relay all emails through the SMTP relay'
echo '(2) Relay only emails to external domains'
echo
echo -n 'Selection [1 or 2]= '
read tselect
done

echo
if [ "${tselect}" == "1" ] ; then
  echo 'TRANSPORT: All emails will be sent via SMTP relay.'
elif [ "${tselect}" == "2" ] ; then
  echo 'TRANSPORT: Only emails outbound to internet domains will be relayed.'
fi 
echo

echo '########################'
echo '## READY TO CONFIGURE ##'
echo '########################'
echo
cont=0
while [ "${cont}" != "continue" ] ; do
echo -n 'Type "continue" to run the configuration = '
read cont
done

function installPostfixPackages() {

packages=""
if [ ! -f "$(which postfix 2>&1)" ] ; then
  packages="${packages} postfix"
fi
if [ ! -f "$(which mail 2>&1)" ] ; then
  packages="${packages} mailx"
fi
if [ ! -f "/usr/lib64/sasl2/liblogin.so" ] ; then
  packages="${packages} cyrus-sasl-plain"
fi

if [ ! -z "${packages}" ] ; then
  dnf -y install ${packages}
fi
}

installPostfixPackages

# Back up existing configuration
if [ ! -f /etc/postfix/main.cf.original ] ; then
  echo 'Backing up original Postfix configuration...'
  cp -av /etc/postfix/main.cf /etc/postfix/main.cf.original
  cp -av /etc/postfix/master.cf /etc/postfix/master.cf.original
  if [ -f /etc/postfix/transport ] ; then
    cp -av /etc/postfix/transport /etc/postfix/transport.original
  fi
  if [ -f /etc/postfix/sasl_passwd ] ; then
    cp -av /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.original
  fi
fi

if [ "${tselect}" == "1" ] ; then

echo 'Configuring main.cf...'
postconf -ev "relayhost = [${smtp}]:${port}" \
             "smtp_sasl_auth_enable = yes" \
             "smtp_sasl_security_options = noanonymous" \
             "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" \
             "smtp_use_tls = yes" \
             "smtp_tls_security_level = encrypt" \
             "smtp_tls_note_starttls_offer = yes" \
             "smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt"

elif [ "${tselect}" == "2" ] ; then

echo 'Configuring main.cf...'
postconf -ev "smtp_sasl_auth_enable = yes" \
             "smtp_sasl_security_options = noanonymous" \
             "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" \
             "smtp_use_tls = yes" \
             "smtp_tls_security_level = encrypt" \
             "smtp_tls_note_starttls_offer = yes" \
             "transport_maps=hash:/etc/postfix/transport" \
             "inet_interfaces=all" \
             "smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt"

echo 'Configuring transport...'
cat << eof > /etc/postfix/transport
local :
.local :
$(hostname -d) :
.$(hostname -d) :
* smtp:[${smtp}:${port}]
eof
postmap -v hash:/etc/postfix/transport

fi

echo 'Configuring sasl_passwd...'
cat << eof > /etc/postfix/sasl_passwd
[${smtp}]:${port} ${user%%@*}:${pass}
eof
postmap -v hash:/etc/postfix/sasl_passwd


echo 'Configuring permissions...'
if [ "${tselect}" == "1" ] ; then
chown -v root:root /etc/postfix/main.cf /etc/postfix/transport /etc/postfix/sasl_passwd
chmod -v 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
elif [ "${tselect}" == "2" ] ; then
chown -v root:root /etc/postfix/main.cf /etc/postfix/sasl_passwd
chmod -v 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
fi

echo 'Saving ~/.email'
echo ${email}>~/.email
echo 'Saving ~/.emailfrom'
echo ${emailfrom}>~/.emailfrom

echo 'Starting and enabling the postfix service...'
# `postfix reload` also works
systemctl status postfix
systemctl enable postfix
systemctl is-enabled postfix
systemctl restart postfix
systemctl status postfix

# Send a test email optionally
echo -n "Send a test email? (y/n)="
read k
if [ "${k}" == "y" ] || [ "${k}" == "Y" ] ; then
  echo -n "Destination address [${email}] ="
  read addr
  if [ ! -z "${addr}" ] ; then
    email=${addr}
  fi

  echo 'This is a test message.' | mail -r ${emailfrom} -s "Test message from $(hostname -f)" ${email}
fi


