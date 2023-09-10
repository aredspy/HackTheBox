# Valentine (HackTheBox)

## Severity High: Publicly Accessible Encrypted Backup of SSH Key

A file containing an encrypted SSH private key was found on the Valentine machine in the `https://10.10.10.79/dev` directory belonging to the `hype` user. Public access to an encrypted SSH key file can allow attackers to potentially decrypt the file if it uses a weak password or utilize a discovered credential to decrypt it and gain further access on the network. The file was successfully decrypted using information from the "heartbleed" exploit below, compromising the `hype` user and any services connected to it.

![pic](snaps/file1.png)

Using the network scanning tool "nmap", the target host was revealed to have an open port `80` and `443` running `Apache/2.2.22`. The scan further revealed the `/dev` directory which can be accessed with a web browser. After downloading the file and decoding with base 64, it was revealed to be a RSA private key used for SSH connections.

![pic](snaps/file3.png)

![pic](snaps/file2.png)

### Remediation

In order to prevent attacks utilizing found encrypted user credentials, it is recommended to adopt a policy of ensuring user keys are not stored with reversible encryption or backed up to an external file. It is also recommended to remove the `/dev` directory from the public web server to prevent unauthorized access to any files or information regarding the development of the website. Information on configuring Apache's directories can be found at https://httpd.apache.org/docs/trunk/mod/core.html#directory.


## Severity Critical: CVE-2014-0160 OpenSSL Heartbleed Vulnerability

An Apache web server vulnerable to the "heartbleed" exploit was found running on the Valentine machine. The vulnerability allows attackers to access memory outside what the web server should have access to, resulting in loss of critical information such as the SSL private keys which can be used to impersonate services and users on the network and completely decrypt network traffic. The "heartbleed" exploit was successfully run on Valentine to expose the password for the encrypted SSH key detailed above.

![pic](snaps/hb1.png)

![pic](snaps/hb4.png)

Using the network scanning tool "nmap", the target host was revealed to have an open port `80` and `443` running `Apache/2.2.22`. A secondary "nmap" script scan showed the web server was vulnerable to CVE-2014-0160. Using the exploit framework "Metasploit", a heartbleed module was run against the server which allowed the dumping of private SSL keys and arbitrary data loaded into memory. From the data dump, a base 64 string was found which was discovered to be the password to the SSH key of the `hype` user. The SSH key was then used to login as the `hype` user on the target host.

![pic](snaps/hb2.png)

![pic](snaps/hb3.png)

![pic](snaps/hb5.png)

### Remediation

To prevent attacks or data loss utilizing "heartbleed", it is recommended to update OpenSSL to the latest version and apply any security patches as soon as possible. It is also recommended to regenerate all SSL keys/certificates to ensure any potentially leaked keys are no longer useful to an attacker. Further information on understanding and mitigating "heartbleed" can be found at https://heartbleed.com/.


## Severity Critical: CVE-2021-4034 PKExec Privilege Escalation

The Valentine machine was found to be running on a vulnerable linux kernel version `3.2.0-23`. The kernel is exposed to the CVE-2021-4034 PKExec vulnerability allowing an attacker to gain full privileges as the root user. Using the existing compromised user `hype`, access to a root shell was gained by running the exploit on the target machine, compromising all services and devices connected to the machine.

![pic](snaps/pk1.png)

Using the network scanning tool "nmap", the target host was revealed to have an open port `22` running `OpenSSH 5.9p1`. Using the SSH user key discovered and decrypted (detailed above), the target host was accessed under the `hype` user. The vulnerability analysis tool "linpeas" was then used to identify potential escalation vectors and known CVE exposure. Creating the exploit binary using  published script (https://www.exploit-db.com/exploits/50689) was done in a writable directory, and then executed to spawn a root shell compromising the entire system and any services running on it. 

![pic](snaps/pk3.png)

![pic](snaps/pk2.png)

### Remediation

To prevent privilege escalation by an attacker, it is recommended to update the `polkit` package to the latest version or upgrade the kernel to the latest stable release. If it is currently impossible to update either `polkit` or the kernel, a guide on a script based mitigation can be followed at https://access.redhat.com/security/vulnerabilities/RHSB-2022-001.