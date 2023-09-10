# Devel (HackTheBox)

## Severity High: Anonymous FTP with Write Permissions in Web Root Directory

An anonymously accessible **FTP** server was found running in the Internet Information Services (**IIS**) web root directory on the ***Devel*** machine. Allowing public read and write access can result in compromised data loss as well as a vector for attacks on other services running on the same machine. In this scenario, the **FTP** server was abused to upload malicious reverse shell files which would then be executed by **IIS**, providing a foothold on the target host in the form of a shell under the `iis apppool` user (see **ASPX** vulnerability below).

![pic](snaps/ftp1.png)

Using the network scanning tool ***nmap*** the target host was revealed to have an open port `21` running `Microsoft ftpd` with anonymous login allowed. The scan results revealed the root directory was the same as the `wwwroot` used by the **IIS** web server Accessing the server through `ftp` further revealed the directory was writable, allowing any file to be uploaded or downloaded. Using another vulnerability detailed below, a reverse shell was uploaded and executed to gain access to the system, compromising services under the builtin `IIS_IUSRS` group.

![pic](snaps/ftp2.png)

![pic](snaps/ftp3.png)

### Remediation

To prevent unauthorized access to the **FTP** server, it is recommended to enable password authentication for all connections as well as upgrade to **SFTP** or **FTPS** to ensure all connections remain encrypted. Furthermore, the **FTP** server should be reconfigured with appropriate permissions to allow access to a dedicated directory to prevent users or attackers from gaining access to reading or writing files shared with another service. Information regarding **IIS**'s **FTP** service configuration and security can be found at https://winscp.net/eng/docs/guide_windows_ftps_server.



## Severity High: IIS ASPX Execution Policy

An Internet Information Services (**IIS**) web server was discovered running on the ***Devel*** machine with an unsafe `.aspx` execution policy. Allowing a web server such as **IIS** to run **ASPX** based scripts when not required by the web site can allow attackers to abuse any file upload or `HTTP POST` methods to make the server execute malicious code. This can result in both confidential data loss as well as loss of web services if an attacker takes control of the **IIS** service in the target host.

![pic](snaps/aspx0.png)

![pic](snaps/aspx1.png)

Using the network scanning tool ***nmap*** the target host was revealed to have an open port `80` running `Microsoft IIS httpd 7.5`. Further probing with the web scanning tool ***gobuster*** showed the web server accepts requests to resources with the `*.aspx` extension, hinting that the web server has **ASPX** execution enabled. Using the aforementioned anonymous **FTP** upload, a reverse shell written in **ASPX** was uploaded and then succesfully executed by accessing `http://10.10.10.5/shell.aspx` in the web browser. The opened **CMD** session allowed limited traversal of the file system and interaction with the target host **OS**.

![pic](snaps/aspx2.png)

![pic](snaps/aspx3.png)

### Remediation

To prevent attacks utilizing **IIS**'s **ASPX** capability, it is recommended to disable `.aspx` scripts when not required by the web page. If **ASPX** is important to the web site, it is recommended to follow proper security procedure to configure `ASP.NET` with a Windows security context. Information on securing **IIS**'s app pools and setting the `ASP.NET` to impersonation authentication can be found at https://docs.microsoft.com/en-us/iis/application-frameworks/scenario-build-an-aspnet-website-on-iis/configuring-step-4-configure-application-security. 



## Severity Critical: MS13-053 Privilege Escalation Vulnerability

The ***Devel*** machine was discovered to have an unpatched version of `Windows 7 Enterprise` with a known privilege escalation vulnerability. MS13-053 takes advantage of a bug in certain kernel mode drivers to create an instance of a shell running as the root `NT AUTHORITY\SYSTEM` user. Unpatched systems with published exploits can allow attackers to rapidly compromise entire machines as well as services and other devices connected to the target host(s). 

![pic](snaps/ms0.png)

![pic](snaps/ms1.png)

After gaining access with the **FTP** and **ASPX** vulnerability explained above, the target system was scanned for further vulnerabilities using the `winPEAS.bat` tool. The tool revealed the target operating system was missing critical security patches for `7SP0/SP1` (Windows 7) and potentially vulnerable to several published exploits. Using the exploit framework ***Metasploit***, a module for the MS13-053 vulnerability was loaded and executed against the already open shell session, resulting in an elevated root session providing access to the entire system. 

![pic](snaps/ms2.png)

![pic](snaps/ms3.png)

### Remediation

to prevent attacks utilizing MS13-053 or other published Windows vulnerabilities, it is recommended to update the machine to the latest version of Windows and apply all security updates. If the machine is in an enterprise environment/domain, security updates should be enabled to be pushed to all machines by default by the update server. Further information regarding MS13-053 and security patching can be found at https://docs.microsoft.com/en-us/security-updates/securitybulletins/2013/ms13-053.