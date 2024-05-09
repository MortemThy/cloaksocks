#!/bin/bash

# OS and distrib type detection and preinstall packages
InstallDep(){
	os_type=$(uname -s)
	case "$os_type" in
		Linux)
			if [ -f /etc/lsb-release ]; then
				# Ubuntu
				apt list --installed 2> /dev/null| grep docker-ce
				if [ $? -eq 1 ]; then
					apt-get update
					apt-get install -y apt-transport-https ca-certificates curl software-properties-common
					curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
					echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
					apt-get update
					apt-get install -y docker-ce docker-ce-cli containerd.io
					systemctl start docker
				fi

				apt list --installed 2> /dev/null|grep "docker-compose/"
				if [ $? -eq 1 ]; then
					curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
					-o /usr/local/bin/docker-compose
					chmod +x /usr/local/bin/docker-compose
				fi

				apt list --installed 2> /dev/null| grep qrencode
				if [ $? -eq 1 ]; then
					apt-get install -y qrencode
				fi
			elif [ -f /etc/arch-release ]; then
				# Arch Linux
				pacman -Qs docker > /dev/null
				if [ $? -eq 1 ]; then
					pacman -Syu --noconfirm
					pacman -S --noconfirm docker
					systemctl start docker
				fi

				pacman -Qs docker-compose > /dev/null
				if [ $? -eq 1 ]; then
					pacman -S --noconfirm docker-compose
				fi

				pacman -Qs qrencode > /dev/null
				if [ $? -eq 1 ]; then
					pacman -S --noconfirm qrencode
				fi
			elif [ -f /etc/centos-release ]; then
				# CentOS
				rpm -qa | grep docker-ce > /dev/null
				if [ $? -eq 1 ]; then
					yum install -y yum-utils
					yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
					yum install -y docker-ce docker-ce-cli containerd.io
					systemctl start docker
				fi

				rpm -qa | grep docker-compose > /dev/null
				if [ $? -eq 1 ]; then
					curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" \
					-o /usr/local/bin/docker-compose
					chmod +x /usr/local/bin/docker-compose
				fi

				rpm -qa | grep qrencode > /dev/null
				if [ $? -eq 1 ]; then
					yum install -y qrencode
				fi
			elif [ -f /etc/debian_version ]; then
				# Debian
				apt list --installed 2> /dev/null| grep docker-ce
				if [ $? -eq 1 ]; then
					apt-get update
					apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
					curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
					echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
					apt-get update
					apt-get install -y docker-ce docker-ce-cli containerd.io
					systemctl start docker
				fi

				apt list --installed 2> /dev/null|grep "docker-compose/"
				if [ $? -eq 1 ]; then
					curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
					-o /usr/local/bin/docker-compose
					chmod +x /usr/local/bin/docker-compose
				fi

				apt list --installed 2> /dev/null| grep qrencode
				if [ $? -eq 1 ]; then
					apt-get install -y qrencode
				fi
			else
				echo "Unsupported Linux distribution."
				exit 1
			fi
			;;
		*)
			echo "Unsupported operating system."
			exit 1
			;;
	esac
}

ChmodBin(){
	if [ -x bin/ck-server ]
	then
		QueryInfo
	else
		chmod +x bin/ck-server
		QueryInfo
	fi
}

QueryInfo(){
	DefIP=$(curl -s https://ipecho.net/plain)
	KEYPAIRS=$(bin/ck-server -key)
	PrivateKey=$(echo $KEYPAIRS | cut -d" " -f13)
	PublicKey=$(echo $KEYPAIRS | cut -d" " -f5)
	CloakUID=$(bin/ck-server -uid | cut -d" " -f4)
}

ReadArgs(){
	echo
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓   Shadowsocks over Cloak on docker    ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo

	# set cloak options
	read -e -p "Enter server IP Address or hostname: " -i "$DefIP" LOCAL_IP
	read -e -p "Enter Shadowsocks Port: " -i "8399" LOCAL_PORT
	read -e -p "Enter ByPassUID: " -i "$CloakUID" BYPASSUID
	read -e -p "Enter PrivateKey: " -i "$PrivateKey" PRIVATEKEY
	read -e -p "Enter PublicKey: " -i "$PublicKey" PUBLICKEY
	echo

	# set cloak encryption options
	OPTIONS=("aes-256-gcm" "aes-128-gcm" "chacha20-ietf-poly1305")

	echo "Encryption methods: "
	for i in "${!OPTIONS[@]}"; do
	    echo "$(($i+1))) ${OPTIONS[$i]}"
	done

	while true; do
	    read -e -p "Select Encryption method (chacha20-ietf-poly1305 is the default value. Other ciphers might not work.): " CHOICE
	    if [[ $CHOICE -ge 1 && $CHOICE -le ${#OPTIONS[@]} ]]; then
	        ENCRYPTION=${OPTIONS[$(($CHOICE-1))]}
	        break
	    else
	        echo "Invalid input. Please enter a number between 1 and ${#OPTIONS[@]}."
	    fi
	done
	echo

	# set cloak listening port 
	read -e -p "Enter Cloak Port (443 is strongly recommended): " -i "443" BINDPORT
	stty echo
	echo

	# shadowsocks password
	read -p "Enter Password: " -i "" PASSWORD
	stty echo
	echo
	echo

	# set cloak AdminUID
	echo "Enter AdminUID (Optional): "
	echo
	echo "1) UseByPassUID as AdminUID (Recommended)"
	echo "2) Generate new UID and set it as AdminUID"
	echo "3) Ignore"
	read -r -p "Select an Option or Enter AdminUID: " -i "1" OPTIONS
	case $OPTIONS in
	1)
		ADMINUID=$BYPASSUID;;
	2)
		ADMINUID=$(bin/ck-server -uid | cut -d" " -f4)
		echo "Your AdminUID: $ADMINUID";;
	*)
		ADMINUID=$OPTIONS;;
	esac
	echo

    # set cloak spoofed redirect address
	OPTIONS=("Cloudflare (1.0.0.1)" "www.bing.com" "www.google.com" "m.youtube.com")

	echo "Enter Redirect Address: "
	echo

	for ((i=0; i<${#OPTIONS[@]}; i++)); do
	    echo "$((i+1))) ${OPTIONS[i]}"
	done

	while true; do
	    read -r -p "Select an Option (1-${#OPTIONS[@]}) or Enter an Address: " -i "1" OPTION

	    if [[ "$OPTION" =~ ^[1-${#OPTIONS[@]}]$ ]]; then
	        REDIRADDR=${OPTIONS[OPTION-1]}
	        break
	    elif [[ -n "$OPTION" ]]; then
	        REDIRADDR=$OPTION
	        break
	    else
	        echo "Invalid Option. Please select 1-${#OPTIONS[@]} or enter an address."
	    fi
	done
	echo

	# set cloak spoofed browser signature
	OPTIONS=("chrome" "firefox" "safari")

	echo "Browser signature: "
	echo

	for ((i=0; i<${#OPTIONS[@]}; i++)); do
	    echo "$((i+1)) ${OPTIONS[i]}"
	done

	while true; do
	    read -r -p "Select Browser signature (is the browser you want to APPEAR to be using. It's not relevant to the browser you are actually using.): " OPTION

	    if [[ "$OPTION" =~ ^[1-${#OPTIONS[@]}]$ ]]; then
	        BROWSERSIG=${OPTIONS[OPTION-1]}
	        break
	    elif [[ -n "$OPTION" ]]; then
	        BROWSERSIG=$OPTION
	        break
	    else
	        echo "Invalid Option. Please select 1-${#OPTIONS[@]} or enter a custom signature."
	    fi
	done
	echo

	# cloak amount of TCP connections
	echo "Set amount of TCP connections you want to use : "
	read -e -p "Enter number: " -i "4" NUMCONN
	stty echo
	echo
}

# generating docker-compose.yml
ReplaceArgs(){
	cp docker-compose-server.yaml docker-compose.yml
	sed -i "s|\$LOCAL_IP|${LOCAL_IP}|" docker-compose.yml 
	sed -i "s|\$LOCAL_PORT|${LOCAL_PORT}|g" docker-compose.yml
	sed -i "s|\$BYPASSUID|${BYPASSUID}|" docker-compose.yml
	sed -i "s|\$PRIVATEKEY|${PRIVATEKEY}|" docker-compose.yml
	sed -i "s|\$PUBLICKEY|${PUBLICKEY}|" docker-compose.yml
	sed -i "s|\$ENCRYPTION|${ENCRYPTION}|" docker-compose.yml
	sed -i "s|\$PASSWORD|${PASSWORD}|" docker-compose.yml
	sed -i "s|\$ADMINUID|${ADMINUID}|" docker-compose.yml
	sed -i "s|\$REDIRADDR|${REDIRADDR}|" docker-compose.yml
	sed -i "s|\$BINDPORT|${BINDPORT}|g" docker-compose.yml
}

# generating ssserver.conf
GenSsConfig(){
	echo '{
	"server": "0.0.0.0",
	"server_port": $LOCAL_PORT,
	"local_address": "0.0.0.0",
	"password": "$PASSWORD",
	"timeout": 300,
	"method": "$ENCRYPTION"
}' > config/ssserver.conf

	sed -i "s|\$LOCAL_PORT|${LOCAL_PORT}|g" config/ssserver.conf
	sed -i "s|\$PASSWORD|${PASSWORD}|" config/ssserver.conf
	sed -i "s|\$ENCRYPTION|${ENCRYPTION}|" config/ssserver.conf
}

# generating ckserver.json
GenCkServerJson(){
	echo '{
  "ProxyBook": {
	"shadowsocks": [
	  "tcp",
	  "0.0.0.0:$LOCAL_PORT"
	]
  },
  "BindAddr": [
	":$BINDPORT",
	":80"
  ],
  "BypassUID": [
	"$BYPASSUID"
  ],
  "RedirAddr": "$REDIRADDR",
  "PrivateKey": "$PRIVATEKEY",
  "AdminUID": "$ADMINUID",
  "DatabasePath": "userinfo.db"
}' > config/ckserver.json

	sed -i "s|\$LOCAL_PORT|${LOCAL_PORT}|g" config/ckserver.json
	sed -i "s|\$BINDPORT|${BINDPORT}|g" config/ckserver.json
	sed -i "s|\$BYPASSUID|${BYPASSUID}|" config/ckserver.json
	sed -i "s|\$REDIRADDR|${REDIRADDR}|" config/ckserver.json
	sed -i "s|\$PRIVATEKEY|${PRIVATEKEY}|" config/ckserver.json
	sed -i "s|\$ADMINUID|${ADMINUID}|" config/ckserver.json
}

# generating ckclient.json
GenCkClientJson(){
	echo '{
  "Transport": "direct",
  "ProxyMethod": "shadowsocks",
  "EncryptionMethod": "plain",
  "UID": "$BYPASSUID",
  "PublicKey": "$PUBLICKEY",
  "ServerName": "$REDIRADDR",
  "NumConn": $NUMCONN,
  "BrowserSig": "$BROWSERSIG",
  "StreamTimeout": 300
}' > config/ckclient.json

	sed -i "s|\$BYPASSUID|${BYPASSUID}|" config/ckclient.json
	sed -i "s|\$PUBLICKEY|${PUBLICKEY}|" config/ckclient.json
	sed -i "s|\$REDIRADDR|${REDIRADDR}|" config/ckclient.json
	sed -i "s|\$NUMCONN|${NUMCONN}|" config/ckclient.json
	sed -i "s|\$BROWSERSIG|${BROWSERSIG}|" config/ckclient.json
}

# create users database file for adminpanel
InitDB(){
	local dir="db"
	local file="userinfo.db"

	if [ ! -d "$dir" ]; then
		mkdir -p "$dir"  
		echo "Database directory '$dir' created."
	else
		echo "Database directory '$dir' already exists."
	fi

	cd "$dir" || return

	if [ ! -f "$file" ]; then
		touch "$file"  
		echo "Database '$file' created. in '$dir'"
	else
		echo "File '$file' already exists in '$dir'."
	fi
	cd ..
}

# generating client configs 
ShowConnectionInfo(){
	SERVER_BASE64=$(printf "%s" "$ENCRYPTION:$PASSWORD" | base64)
	SERVER_CLOAK_ARGS="ck-client;StreamTimeout=300;PublicKey=$PUBLICKEY;EncryptionMethod=plain;TicketTimeHint=3600;MaskBrowser=chrome;ProxyMethod=shadowsocks;UID=$BYPASSUID;CDNWsUrlPath=;AlternativeNames=;KeepAlive=0;ServerName=$REDIRADDR;BrowserSig=$BROWSERSIG;Transport=direct;CDNOriginHost=;NumConn=$NUMCONN"
	SERVER_CLOAK_ARGS=$(printf "%s" "$SERVER_CLOAK_ARGS" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-)
	SERVER_BASE64CK="ss://$SERVER_BASE64@$LOCAL_IP:$BINDPORT?plugin=$SERVER_CLOAK_ARGS#cloaksocks"
	SERVER_BASE64SS="ss://$SERVER_BASE64@$LOCAL_IP:$LOCAL_PORT#shadowsocks"
}

# showing clients connection info, and save into CloakSocks.README
GenReadme(){
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓    Shadowsocks over Cloak on docker   ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓   READ CAREFULLY TO MAKE THINGS WORK  ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓   (text saved to CloakSocks.README)   ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo
	echo "0. Start server with 'docker-compose up -d'"
	echo
	echo "1. For Android - install Shadowsocks Client:"
	echo "https://f-droid.org/en/packages/com.github.shadowsocks/index.html.en"
	echo
	echo "2. Install Cloak Android plugin:"
	echo "https://apt.izzysoft.de/fdroid/index/apk/com.github.shadowsocks.plugin.ck_client"
	echo
	echo "3. Make sure you have the Cloak for Android installed and then Scan this QR:"
	echo
	qrencode -t ansiutf8 "$SERVER_BASE64CK"
	echo
	echo "Or just use this one-string config:"
	echo
	echo $SERVER_BASE64CK
	echo
	echo
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"	
	echo
	echo
	echo "Next, QR-code and config, for DIRECT connection to Shadowsocks server, bypassing Cloak."
	echo "Which less secure, but useful for client apps without the Cloak plugin, like iOs and MacOs "
	echo
	echo "4. For iOs - install Potatso App from AppStore https://apps.apple.com/us/app/potatso/id1239860606"
	echo "and scan next QR code:"
	echo
	qrencode -t ansiutf8 "$SERVER_BASE64SS"
	echo
	echo "5. For Linux - install: https://github.com/nojsja/shadowsocks-electron/releases"
	echo
	echo "6. For Windows - install: https://github.com/HirbodBehnam/Shadowsocks-Cloak-Installer/blob/master/README.MD#windows"
	echo
	echo "7. For MacOs - install https://github.com/shadowsocks/ShadowsocksX-NG/releases"
	echo
	echo "And use this one-string config:"
	echo
	echo $SERVER_BASE64SS
	echo
	echo "8. For use config management panel:"
	echo 
	echo "On your local linux machine, first download "ck-client" binary, and "ckclient.json", from server project's "bin" and "config" folders, then run:"
	echo "./ck-client -s $LOCAL_IP -l $LOCAL_PORT -a $ADMINUID -c ckclient.json"
	echo 
	echo "Visit https://cbeuw.github.io/Cloak-panel where open admin panel 127.0.0.1:$LOCAL_PORT )."
	echo "Add user config UIDs with desired configurations"
	echo
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ h.A.p.P.y d.O.m.A.i.N f.R.o.N.t.I.n.G ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
	echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
}

InstallDep
ChmodBin
QueryInfo
ReadArgs
ReplaceArgs
GenSsConfig
GenCkServerJson
GenCkClientJson
InitDB
ShowConnectionInfo
GenReadme | tee CloakSocks.README