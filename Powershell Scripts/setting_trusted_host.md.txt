For the script that worked we enabled:

TrustedHosts within DC to other hosts (Refer to the IP set below:


To check if you have trusted hosts:

winrm.cmd get winrm/config/client

To set Trusted host on such computers:

winrm.cmd set winrm/config/client '@{TrustedHosts="192.168.56.10,192.168.56.11,192.168.56.12,192.168.56.22,192.168.56.23"}'


After this is done

Execute Script you required.


