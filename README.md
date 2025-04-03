# s3bucket_local_backup
Repository to Backup s3 Bucket(s) to local folder and notify per email (success/failure).

Fillin the bucket name(s) into `buckets.txt`

The script also handles backup retention, you can change values in `s3backup.sh` (line 14+16)

❗ Change line "8+11" in s3backup.sh to your needs. And run `touch /YOUR_BACKUPPATH/.mounted` to make the mount check work.

***


#### First of all install `awscli` package:

From Debian repository:

    sudo apt-get install awscli

Or latest direct from Amazon [(recommended):](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install


***


#### To get the mail notification working follow these steps:



Install mailutils:

    sudo apt-get install mailutils

Choose the unconfigured option if asked.

Install and configure sstmp:

    sudo apt-get install ssmtp
    sudo nano /etc/ssmtp/ssmtp.conf
    
Add the following to the file:


    root=user@gmail.com
    AuthUser=user@gmail.com
    AuthPass=PASSWORD
    mailhub=smtp.gmail.com:587
    UseSTARTTLS=YES


Add mail adress to the user:

    nano /etc/ssmtp/revaliases

If you use the root user as example:

    root:user@gmail.com:smtp.gmail.com:587

Set the FROM name (optional):

    nano /etc/passwd

If you use the root user as example (after that the email is FROM: TEST):

    root:x:0:0:TEST:/root:/bin/bash


To test:

    echo "This is a test" | mail -s "Test" recipient@gmail.com
