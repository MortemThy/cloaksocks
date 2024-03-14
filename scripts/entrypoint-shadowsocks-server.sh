#!/bin/sh

echo
echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓        Shadowsocks RUST Server        ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓                                       ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
echo "░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓ c . L . o . A . k . S . o . C . k . S ▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░"
echo

echo -e '[+] Show Container config'
echo -e "[!] Server IP : \t${SERVER_IP}"
echo -e "[!] Server Port : \t${SERVER_PORT}"
echo -e "[!] Encryption Method:  ${ENCRYPTION}"
echo -e "[!] Password : \t\t${PASSWORD}"

exec ssserver --log-without-time -a nobody -c /etc/shadowsocks-rust/config.json

exec "$@"
