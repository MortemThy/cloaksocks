# Cloaksocks-docker
is a server-side Docker build designed to be installed on Linux servers. It combines the Shadowsocks server with the Cloak server to bypass web censorship, providing secure and anonymous Internet access by bypassing blockers and filters.

**Cloaksocks-docker** simplifies Shadowsocks/Cloak usage with scripts and Dockerfiles, using two Docker containers:

- **Shadowsocks**: A high-speed tunnel proxy facilitating firewall circumvention.
- **Cloak**: A versatile pluggable transport encrypting proxy traffic to mimic legitimate HTTPS traffic, camouflaging the proxy server as a regular web server. It multiplexes traffic through a fixed TCP connection pool and offers multi-user usage control.
Both containers simultaneously listen for client connections, enabling connections with and without the cloak plugin.

This build supports installation on multiple distributions, including **Ubuntu**, **Debian**, **CentOS**, and **Arch** Linux.
Once installed on a server located in a censorship-free region, you can connect to it using various client applications:

- [**Shadowsocks**](https://f-droid.org/en/packages/com.github.shadowsocks/index.html.en) app with [**Cloak**](https://apt.izzysoft.de/fdroid/index/apk/com.github.shadowsocks.plugin.ck_client) plugin for Android,
- [**Potatso**](https://apps.apple.com/us/app/potatso/id1239860606) app for iOS devices (free, no cloak support), [**Shadowrocket**](https://apps.apple.com/us/app/shadowrocket/id932747118) app (paid, supports cloak),
- [**Shadowsocks-electron**](https://github.com/nojsja/shadowsocks-electron/releases) app for Linux (no cloak support),
- [**ShadowsocksX-NG**](https://github.com/shadowsocks/ShadowsocksX-NG/releases) and [**Shadowsocks**](https://apps.apple.com/gb/app/shadowsocks/id1295053131) apps for MacOS, 
- [**Shadowsocks-windows**](https://github.com/HirbodBehnam/Shadowsocks-Cloak-Installer/blob/master/README.MD#windows) app with cloak plugin for Windows.

Cloak plugin support is not available for some operating systems, clients can connect directly to the Shadowsocks server on the port selected during installation.


![Made with](https://img.shields.io/badge/Made%20with-Bash%2FDocker-red)
![ShadowSocks version](https://snapcraft.io/shadowsocks-rust/badge.svg)
![Cloak version](https://img.shields.io/badge/Cloak_version-2.6.0-blue)
![Dockerfile](https://img.shields.io/badge/Dockerfile-Ready-brightgreen)
![Docker Compose](https://img.shields.io/badge/Docker_Compose-Ready-brightgreen)
![Docker Build](https://img.shields.io/badge/Docker_Build-Automatic-brightgreen)

![cloaksocks2](https://github.com/cloaksocks/cloaksocks-docker/assets/157986562/70c765fd-e382-45ea-967b-79f1b79c9550)



# How to utilize
**You have many options:**
## Use the shell script
Using `Cloaksocks.sh` is the recommended action:

```bash
git clone https://github.com/cloaksocks/cloaksocks-docker
cd cloaksocks-docker
chmod +x Cloaksocks.sh
sudo ./Cloaksocks.sh
```

- Then follow the instructions to install and confiure. Fast and Simple. Script creates a docker-compose.yml with your desired configuration, then displays **configs** and **QR-codes** to adding configs for mobile and desktop Shadowsocks client applications.

- Then you must start the stack with command:
```bash
docker-compose up -d
```
or
```bash
docker-compose up
```
to see server logs output.

- Scan QR-codes with mobile Shadowsocks app, and use one-line configs with desktop application.
- The guide with QR codes shown in the server terminal is also saved in the ```CloakSocks.README``` file on your server so you don't lose it.
- Enjoy your new cloaksocks server, now you're lurking in the shadows.

## Use docker-compose directly
In case you want to manually configure the `docker-compose` file, make sure to check the "Supported Variables" section first.
Then simply edit and run `docker-compose-server.yaml`

```bash
docker-compose -f docker-compose-server.yaml up -d
```

# User config management and Admin panel.

### Unrestricted users
Just use one generated config for all users.

### Users subject to bandwidth and credit controls
0. First make sure you have ```AdminUID``` generated and set in ```ckserver.json```, along with a path to ```userinfo.db``` in ```DatabasePath``` (Cloak will create this file in ```config``` folder for you if it didn't already exist).
1. On a Linux, download ```ck-client``` from ```bin``` folder of your server and ```ckclient.json``` from ```config``` folder.
2. To enter admin mode, on your client **use generated command string below qr-codes in your server output (which also saved in CloakSocks.README)**. Or run ```ck-client -s <IP of the server> -l <A local port> -a <AdminUID> -c <path-to-ckclient.json>```.
3. Visit [https://cbeuw.github.io/Cloak-panel](https://cbeuw.github.io/Cloak-panel) (Note: this is a pure-js static site, there is no backend and all data entered into this site are processed between your browser and the Cloak API endpoint you specified. Alternatively you can download the repo at [https://github.com/cbeuw/Cloak-panel](https://github.com/cbeuw/Cloak-panel) and open ```index.html``` in a browser. No web server is required).
4. Type in ```127.0.0.1:<shadowsocks port, you entered, through installation (default 8399)>``` as the API Base, and click ```List```.
5. You can add in more users, each with unique settings, by clicking the ```+``` panel

# Dockerfiles

|File name| Description |
|---|---|
|Dockerfile-cloak-server| Alpine container with Cloak Server |
|Dockerfile-shadowsocks-server| Alpine container with ShadowSocks-Rust Server |

# Supported Variables

## Shadowsocks Server
| Key | Default value | Description |
| --- | --- | --- |
| SERVER_IP | `0.0.0.0` | Application listening IP (`0.0.0.0` means `localhost` in Docker) |
| SERVER_PORT | `8399` | Application listening Port |
| ENCRYPTION | `CHACHA20_IETF_POLY1305` | Shadowsocks Server encryption method (Better use the default value. Other Ciphers might not work.) | 
| PASSWORD | `null` | Your password |

## Cloak Server
| Key | Description |
| --- | --- |
| LOCAL_IP | Your server IP |
| LOCAL_PORT | Application listening port (Default `8399`) |
| METHOD | In this project `shadowsocks` |
| BYPASSUID | UID Genetated by Cloak that is authorised without any restrictions. `ck-server -uid` |
| REDIRADDR | Redirection address when the incoming traffic is not from a Cloak client. (Ideally it should be set to a major website allowed by the censor.) |
| PRIVATEKEY | Static curve25519 Diffie-Hellman private key encoded in base64. `ck-server -k` |
| ADMINUID | UID of the admin user in base64 (Optional) `ck-server -uid` |

## Cloak Client
| Key | Default value | Description |
| --- | --- | --- |
| TRANSPORT | `direct` | If the server host wishes you to connect to it directly, use direct. `direct/cdn` |
| METHOD | `shadowsocks` | The proxy method you are using. |
| ENCRYPTION | `plain` |  Encryption algorithm you want **Cloak Client** to use. `plain/aes-256-gcm/aes-128-gcm/chacha20-poly1305`. Use `plain` SS encrypts your data itself.<br />[*not to be confused with SS SERVER `ENCRYPTION`*] |
| CLIENTUID | UID obtained in the previous table | UIDs that are authorised without any bandwidth or credit limit restrictions. |
| PUBLICKEY | PubKey obtained in the previous table | Is the static curve25519 public key. |
| SERVERNAME | `1.0.0.1` | domain you want to make your ISP or firewall think you are visiting. Better be the same value as REDIRADDR |
| BROWSER | `chrome` | the browser you want to appear to be using. It's not relevant to the browser you are actually using. `chrome/firefox/safari` |
| BINDPORT | `443` | The port used by Cloak Server |
| CONNECTIONNUM | `4` | amount of underlying TCP connections you want to use. |
| ADMINUID | Admin UID obtained in the previous table | |

# Cloak Configuration
[Cloak Manual - Offical Repo.](https://github.com/cbeuw/Cloak/blob/master/README.md)

### Server
`RedirAddr` is the redirection address when the incoming traffic is not from a Cloak client. It should either be the same as, or correspond to the IP record of the `ServerName` field set in `ckclient.json`.

`BindAddr` is a list of addresses Cloak will bind and listen to (e.g. `[":443",":80"]` to listen to port 443 and 80 on all interfaces)

`ProxyBook` is a nested JSON section which defines the address of different proxy server ends. For instance, if OpenVPN server is listening on 127.0.0.1:1194, the pair should be `"openvpn":"127.0.0.1:1194"`. There can be multiple pairs. You can add any other proxy server in a similar fashion, as long as the name matches the `ProxyMethod` in the client config exactly (case-sensitive).

`PrivateKey` is the static curve25519 Diffie-Hellman private key encoded in base64.

`AdminUID` is the UID of the admin user in base64.

`BypassUID` is a list of UIDs that are authorised without any bandwidth or credit limit restrictions

`DatabasePath` is the path to userinfo.db. If userinfo.db doesn't exist in this directory, Cloak will create one automatically. **If Cloak is started as a Shadowsocks plugin and Shadowsocks is started with its working directory as / (e.g. starting ss-server with systemctl), you need to set this field as an absolute path to a desired folder. If you leave it as default then Cloak will attempt to create userinfo.db under /, which it doesn't have the permission to do so and will raise an error. See Issue #13.**

### Client
`UID` is your UID in base64.

`Transport` can be either `direct` or `CDN`. If the server host wishes you to connect to it directly, use `direct`. If instead a CDN is used, use `CDN`.

`PublicKey` is the static curve25519 public key, given by the server admin.

`ProxyMethod` is the name of the proxy method you are using.

`EncryptionMethod` is the name of the encryption algorithm you want Cloak to use. Note: Cloak isn't intended to provide transport security. The point of encryption is to hide fingerprints of proxy protocols and render the payload statistically random-like. If the proxy protocol is already fingerprint-less, which is the case for Shadowsocks, this field can be left as `plain`. Options are `plain`, `aes-gcm` and `chacha20-poly1305`.

`ServerName` is the domain you want to make your ISP or firewall think you are visiting.

`NumConn` is the amount of underlying TCP connections you want to use. The default of 4 should be appropriate for most people. Setting it too high will hinder the performance. 

`BrowserSig` is the browser you want to **appear** to be using. It's not relevant to the browser you are actually using. Currently, `chrome` and `firefox` are supported.

# ShadowSocks Rust Configuration
[Shadowsocks-rust Manual - Offical Repo.](https://github.com/shadowsocks/shadowsocks-rust)

### Server

Start Shadowsocks client and server with:

```sh
sslocal -c config.json
ssserver -c config.json
```


### Client

Start local client with configuration file

```sh
# Read local client configuration from file
sslocal -c /path/to/shadowsocks.json
```

## Fork
This project is fork of [laphrog](https://github.com/laphrog/Cloaksocks) **cloaksocks** project, which based on a great works of: 
[Andy Wang(cbeuw)](https://github.com/cbeuw/Cloak) and [huashaoli](https://github.com/huashaoli/cloak-shadowsocks-docker)

## Support me
Your support will help me continue to improve and maintain this project.

[![Bitcoin Donate Button**](https://img.shields.io/badge/BTC-btc?style=plastic&logo=bitcoin&logoColor=gray&label=Donate&labelColor=%2380cd32&color=lightgray)](bitcoin:3F6HtdX8DnrypFBJKQYZvTGSGhwKaBnuGo?label=donate%20btc%20to%20project%20owner&amp;amount=0.0002)

BTC:```3F6HtdX8DnrypFBJKQYZvTGSGhwKaBnuGo```
