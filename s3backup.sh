#!/bin/bash

# variablen auf Fehler setzen
syncvar=0
copyvar=0
delvar=0

# Ordner älter als die letzten in die variable schreiben
olderthan=13
# Für Tage 1, Für Wochen 7, für Monate 30
retention=7

for line in $(cat buckets.txt)
do
	# Verzeichnis erstellen falls noch nicht vorhanden
	mkdir -p ./$line

	# S3 Bucket in den lokalen Bucketname-Ordner syncen
	aws s3 sync --delete s3://$line ./$line && syncvar=1 || syncvar=0

	# Datumsveriable erstellen/aktuallisieren
	timestamp=$(date +"%d-%m-%Y_%H-%M-%S")

	# Ordner kopieren und mit Datum versehen
	cp -r ./$line ./$line\_$timestamp && copyvar=1 || copyvar=0

	# Ordner zählen
	foldercount=$(find ./$line* -maxdepth 0 -type d | wc -l)

	# wenn #foldercount# über #olderthan#  dann ordner löschen die älter als #olderthan# Wochen sind
	if [ "$foldercount" -gt "$olderthan" ]; then
	   find ./$line\_* -type d -mtime +$(($olderthan*$retention)) -exec rm -rf {} \; 2>/dev/null  && delvar=1 || delvar=0
	fi

	# Benachrichtigung verschicken (per Email)
	if [ "$syncvar" -eq 1 ] && [ "$copyvar" -eq 1 ] && [ "$delvar" -eq 1 ]; then
	   echo "S3Bucket $line Backup successful!" | mail -s "S3Bucket $line Backup successful!" "to@address"
	else
           echo "Sync command successful: $syncvar"; echo "Copy command successful: $copyvar"; echo "Delete command successful: $copyvar"  | mail -s "FAILURE backing up S3Bucket $line!" "to@address"
	fi
done
