# Postman (HackTheBox)

## Severity High: Unauthenticated Redis DB server

A Redis Database server on Postman was found running with no authentication resulting in complete public access. Allowing public access to the service can result in compromised data and data loss such as important internal client information or data being used directly by another service. In this scenario it was found that the "redis" user had write access to a `.ssh` folder allowing an attacker to gain SSH access to the machine by uploading an SSH key. 

![pic](snaps/redis1.png)

![pic](snaps/redis3.png)

Using the network scanning tool "nmap", the target host was revealed to have an open port `6379` running `Redis key-value store 4.0.9` and an open port `22` running `OpenSSH 7.6p1`. Accessing the Redis server was done with `redis-cli -h [HOSTNAME]` which provided a command-line-interface to interact with the Redis database. The CLI can then be used to manipulate key-value pairs on the server including SSH keys. After uploading a valid SSH key, the OpenSSH server accepted a connection with the redis user.

![pic](snaps/redis2.png)

![pic](snaps/redis4.png)

### Remediation

To prevent unauthorized access to the Redis database server, it is recommended to enable password authentication for all connections and generate cryptographically strong passwords with the `ACL GENPASS` command. It is also recommended to remove the `.ssh` folder for the redis user to prevent any incoming SSH connections. Further information about configuring Redis authentication can be found at https://redis.io/docs/manual/security/.



## Severity High: Encrypted Backup of User Credentials

A file containing encrypted user credentials was found on the Postman machine in the `/opt` directory belonging to the `Matt` user. The weak password allows attackers to quickly "decrypt" the password through hashing to discover it as `computer2008`. Known user credentials can be used to access other authenticated services as well as impersonate real user accounts which compromises a large portion of the machine and network.

![pic](snaps/id3.png)

![pic](snaps/id2.png)

Using the network scanning tool "nmap", the target host was revealed to have an open port `22` running `OpenSSH 7.6p1`. Accessing the server was done with the aforementioned Redis vulnerability to login as the redis user. Scanning the file system found the encrypted backup at `/opt/id_rsa.bak`. The backup file is then cracked via password hashing using `john-the-ripper` and a common passwords text file revealing the credentials as `computer2008`. The credentials found can be used to elevate permissions to the `Matt` user as well as gain access to the Webmin server also found running on Postman.

![pic](snaps/id1.png)

![pic](snaps/id4.png)

### Remediation

In order to prevent attacks utilizing found encrypted user credentials, it is recommended to adopt a policy of ensuring user passwords are not stored with reversible encryption or backed up to an external file. It is also recommended to require password complexity to prevent any unintentionally leaked password hashes to be easily "decrypted". Information about id_rsa and proper usage of SSH keys can be found at https://www.ssh.com/academy/ssh/keygen.

## Severity Critical: CVE-2019-12840 Webmin Remote Code Execution

A Webmin web page was found on the Postman machine running an outdated version `1.910` with a known remote code execution (RCE) vulnerability. The Webmin console allows authorized users to upload software package updates which can be abused to send specially formatted data to trigger commands with root privilege. Attackers can utilize this exploit to gain root access to the machine compromising the network and any devices connected to it.

![pic](snaps/webmin1.png)

![pic](snaps/webmin2.png)

Using the network scanning tool "nmap", the target host was revealed to have an open port `10000` running `MiniServ 1.910 (Webmin httpd)`. Accessing the web page through a browser led to a login screen which accepted the credentials discovered from the aforementioned user credentials of `Matt`. The same user credentials were then used to run the RCE exploit in the "Metasploit" framework. The exploit results in a root shell on the target machine ultimately compromising the system and network.

![pic](snaps/webmin3.png)

![pic](snaps/webmin4.png)

### Remediation

To prevent attacks on the Webmin server using CVE-2019-12840, it is recommended to update Webmin to the latest version and apply any security patches published on the Webmin website. To ensure Webmin stays as up to date as possible, it is also recommended to enable automatic updates so security patches and bug fixes will be applied as soon as they are available. The official Webmin security alert can be found at https://www.webmin.com/security.html while a guide on auto updates can be found at https://doxfer.webmin.com/Webmin/Software_Package_Updates.
