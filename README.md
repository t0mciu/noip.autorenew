noip.autorenew
==============

Ussually, when you want to keep alive a hostname of noip.com with a Free Account, they will send you an email every month
to keep alive this hostname in their DNSs. Thus, you will have to manually login in your noip.com account and click in
"Modify" the hostname to avoid deletion of this hostname from their DNS.

Whith this script you only have to place in the device where the hostname wants to be maintained (for example, in your
home Raspberry Pi) and schedule a *cron job* to execute it every 15 days or so.

The script will automatically retrieve the device public IP address and will login into your noip.com account to 
refresh your hostnames.

Output example of the execution

  harvester@lannister ~/noip.autorenew $ ./noip.autorenew.rb <your_noip_login> <your_no_ip_password>
  ======= 2013-07-23 ========
  Getting my current public IP...
  Done: 49.52.2.75
  Sending Keep Alive request to noip.com...
  Done. Keeping alive 2 host with IP '49.52.2.75':
  - testing.testdomain.com
  - felmoltor.testdomain.com
  ===============================


