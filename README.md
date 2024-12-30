# s3bucket_backup
Repository to Backup s3 Bucket to local folder and notify per email (success/failure).

Fillin the bucket name(s) into `buckets.txt`

The script also handles backup retention, you can change values in `s3backup.sh`


***


#### First of all install `awscli` package:

From Debian repository:

    sudo apt-get install awscli

Latest direct from Amazon [(recommended):](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install


***


#### To get the mail notification working follow these steps:

❗ Change line "4" in s3backup.sh to your recipient.



Install mailutils:

    sudo apt-get install mailutils

Choose the unconfigured option if asked.

Install and configure sstmp:

    sudo apt-get install ssmtp
    sudo nano /etc/ssmtp/ssmtp.conf
    
 Add the following to the file:
    
    FromLineOverride=YES
    root=user@gmail.com
    rewriteDomain=gmail.com
    hostname=gmail.com
    realname="Sendername"
    AuthUser=user@gmail.com
    AuthPass=password
    mailhub=smtp.gmail.com:587
    UseSTARTTLS=YES

To test:

    echo "This is a test" | mail -s "Test" <user>@<email>.com
