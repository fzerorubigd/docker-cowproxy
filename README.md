# cow (climb over the wall) Docker image

## Usage

    docker run -d -p 7777:7777 -e 'PROXIES=ss://aes-256-cfb:pass@ip:port,ss://aes-128-cfb:pass@ip:port' -e ALWAYS_PROXY=true -v /home/core/cow:/data fzerorubigd/cow cow

## Volume

/data is available, the blocked, direct file is inside this folder. you can edit them, the stat file and log file are also
stored in this folder, do not modify the stat file manually

## Port

7777 is exposed as and is a HTTP proxy

## Env

This env variables are available :

### PARENT_PROXIES
Comma seperated list of parent proxies. required
Parent proxies are specified with a generic syntax (following RFC 3986):

protocol://[authinfo@]server:port

for specify multiple parent proxies, use ",". Backup load balancing will use
them in order if one fails to connect.

Supported parent proxies and config example:

SOCKS5: socks5://127.0.0.1:1080
HTTP: http://127.0.0.1:8080
HTTP: http://user:password@127.0.0.1:8080
shadowsocks: ss://encrypt_method:password@1.2.3.4:8388
cow: cow://method:passwd@1.2.3.4:4321

NOTE : sshServer is not supported (yet)

in shadowsocks and cow authinfo specifies encryption method and password.
Here are the supported encryption methods:
    aes-128-cfb, aes-192-cfb, aes-256-cfb,
    bf-cfb, cast5-cfb, des-cfb, rc4-md5,
    chacha20, salsa20, rc4, table
    aes-128-cfb is recommended.

### ALWAYS_PROXY

By default, COW only uses parent proxy if the site is blocked.
If this option is true, COW will use parent proxy for all sites.

### LOAD_BALANCE

With multiple parent proxies, COW can employ one of the load balancing
strategies:

   backup:  default policy, use the first prarent proxy in config,
            the others are just backup
   hash:    hash to a specific parent proxy according to host name
   latency: use the parent proxy with lowest connection latency

When one parent proxy fails to connect, COW will try other parent proxies
in order.
Failed parent proxy will be tried with some probability, so they will be
used again after recovery.

### ALLOWED_CLIENT

Specify allowed IP address (IPv4 and IPv6) or sub-network (only IPv4).
Don't forget to specify 127.0.0.1 with this option.
example : 127.0.0.1, 192.168.1.0/24, 10.0.0.0/8

### USER_PASSWORD

Require username and password authentication. COW always check IP in
allowedClient first, then ask for username authentication.

### USER_PASSWORD_FILE

To specify multiple username and password, list all those in a file with
content like this:

   username:password[:port]

port is optional, user can only connect from the specific port if specified.
COW will report error and exit if there's duplicated user.
for using this option, you must make sure that data volume is mounted (-v /some/folder/:/data)
and this option is the file name only!

### AUTH_TIMEOUT

Time interval to keep authentication information.
Syntax: 2h3m4s means 2 hours 3 minutes 4 seconds

### HTTP_ERROR_CODE

Take a specific HTTP error code as blocked and use parent proxy to retry.

### CORE_COUNT

Maximum CPU core to use.

### ESTIMATE_TARGET

cow uses this site to estimate timeout, better to use a fast website.

### TUNNEL_ALLOWED_PORT

Ports allowed to create tunnel (HTTP CONNECT method), comma separated list
or repeat to append more ports.
Ports for the following service are allowed by default:

     ssh, http, https, rsync, imap, pop, jabber, cvs, git, svn

Limiting ports for tunneling prevents exposing internal services to outside.

### DIAL_TIMEOUT

DNS and connection timeout (same syntax with AUTH_TIMEOUT).

### READ_TIMEOUT

Read from server timeout.

### DETECT_SSL_ERROR

Detect SSL error based on client close connection speed, only effective for
Chrome.
This detection is no reliable, may mistaken normal sites as blocked.
Only consider this option when GFW is making middle man attack.

### DEBUG

for enable debug mode in Docker log and the cow itself
