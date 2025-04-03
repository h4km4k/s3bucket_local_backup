#!/bin/bash

#Enable Syslog logging
exec 2> >(logger -s -t $(basename $0))          #nur fehler loggen
#exec 1> >(logger -s -t $(basename $0)) 2>&1    #alles loggen

#Mailempfänger setzen
recipient=empfaenger@test.com

#Backuppfad
backuppath=/mnt/cifs

# Ordner älter als die letzten in die variable schreiben
olderthan=14
# Für Tage 1, Für Wochen 7, für Monate 30
retention=1

for line in $(cat buckets.txt)
do
        # variablen auf Fehler setzen
        cdvar=0
        syncvar=0
        copyvar=0
        delvar=0

        #Check ob cifs gemaounted ist und in das Backupverzeichnis wechseln
        if [ -f /mnt/cifs/.mounted ]; then
                cd $backuppath && cdvar=1 || cdvar=0
        fi

        # S3 Bucket in den lokalen Bucketname-Ordner syncen
        if [ "$cdvar" -eq 1 ]; then
                aws s3 sync --delete s3://$line ./$line && syncvar=1 || syncvar=0
        fi

        # Datumsveriable erstellen/aktuallisieren
        timestamp=$(date +"%d-%m-%Y_%H-%M-%S")

        # Ordner kopieren und mit Datum versehen
#       cp -r $backuppath/$line $backuppath/$line\_$timestamp && copyvar=1 || copyvar=0
        # Ordner komprimieren statt ihn nur zu kopieren
        if [ "$syncvar" -eq 1 ]; then
                mkdir -p $line\_BACKUPS
                tar -czf ./$line\_BACKUPS/$line\_$timestamp.tar.gz ./$line && copyvar=1 || copyvar=0
        fi

        # Ordner zählen
        filecount=$(find ./$line\_BACKUPS/$line* -maxdepth 0 -type f | wc -l)

        # wenn #filecount# über #olderthan#  dann ordner löschen die älter als #olderthan#*#retention sind
        if [ "$copyvar" -eq 1 ]; then
                if [ "$filecount" -gt "$olderthan" ]; then
                        find ./$line\_BACKUPS/$line\_* -type f -mtime +$(($olderthan*$retention)) -exec rm {} \; 2>/dev/null  && delvar=1 || delvar=0
                else
                        delvar=1
                fi
        fi

        # Benachrichtigung verschicken (per Email)
        if [ "$syncvar" -eq 1 ] && [ "$copyvar" -eq 1 ] && [ "$delvar" -eq 1 ]; then
           echo "S3Bucket \"$line\" Backup successful!" | mail -s "S3Bucket \"$line\" Backup successful!" $recipient
        else
           (echo "1=successful / 0=fault"; echo "Change Dir command successful: $cdvar"; echo "Sync command successful: $syncvar"; echo "Copy command successful: $copyvar"; echo "Delete command successful: $delvar") | mail -s "FAILURE backing up S3Bucket \"$line\"!" $recipient
        fi
done
