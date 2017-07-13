#!/bin/bash

nomeprogetto="italiaafuoco"

# impostare path assoluto della cartella di lavoro
cartella=/var/nadir/andrea/script/progetti/emergenzaIncendi
source "$cartella"/anagrafica.txt

# abilito debug
set -x


# verifico la risposta del server
code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$dataurlONA" -u "$usernameONA":"$passwordONA")

if [ $code -eq 200 ]
then

    #creo un file per fare il confronto tra i nuovi dati e i vecchi, vuoto al primo download
	file="$cartella/data/compare.csv"
    if [ -f "$file" ]
        then
            echo "file vuoto"
        else
            cp "$cartella/data/compare.txt" "$cartella/data/compare.csv"
    fi

    # scarico il file
    curl -X GET $dataurlONA -u $usernameONA:$passwordONA | jq . > "$cartella"/data/01"$nomeprogetto".json

	# modifico il json
	cat "$cartella"/data/01$nomeprogetto.json | jq '[.[]|{"instanceID":."meta/instanceID","_uuid":."_uuid","_submission_time":."_submission_time","_attachments":("https://api.ona.io"+._attachments[0].download_url),"id":."_id","nota":."emergenza_widgets/nota","indirizzo":."emergenza_widgets/indirizzo","nome":."anagrafica_widgets/nome","email":."anagrafica_widgets/email","cellulare":."anagrafica_widgets/cellulare","lat":(if (."emergenza_widgets/posizione"  == null) then null else ."emergenza_widgets/posizione"|split(" ")[0] end),"lon":(if (."emergenza_widgets/posizione"  == null) then null else ."emergenza_widgets/posizione"|split(" ")[1] end)}]' > "$cartella"/data/02"$nomeprogetto".json    

	# creo CSV
	cat "$cartella"/data/02"$nomeprogetto".json | in2csv -f json | sed 's/https:\/\/api.ona.io,/,/g'> "$cartella"/data/incendi.csv 



# estraggo solo i record non presenti in archivio. Li ordino per ID, in modo che sia primo il messaggio più vecchio
/usr/local/bin/csvsql --no-inference --query "select * from incendi where id NOT IN (select id  from 'compare') order by id" "$cartella"/data/incendi.csv  "$cartella"/data/compare.csv > "$cartella"/data/trigger.csv

numeroRigheCSV=$(wc -l < "$cartella"/data/trigger.csv )

    if [[ "$numeroRigheCSV" -gt 1 ]]; then
        # estraggo il corpo e creofile
        sed -e '1d'  "$cartella"/data/trigger.csv | csvformat -D "|" > "$cartella"/data/triggerRun.csv

		INPUT="$cartella/data/triggerRun.csv"
		OLDIFS=$IFS
		IFS="|"
		[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
		while read instanceID _uuid _submission_time _attachments id nota indirizzo nome email cellulare lat lon
		do
		data=$(date -d "$_submission_time" +%d/%m/%Y)
			sleep 2
			curl -i -H 'Authorization: token '"$githubTokenExt"'' -d '{ "title": "'"$nota"'", "body": "<pre><yamldata>tel: \u0027'"$cellulare"'\u0027\nemail: '"$email"'\ndescrizione: \u0027'"$nota"'\u0027\nindirizzo: \u0027'"$indirizzo"'\u0027\nlat: '"$lat"'\nlon: '"$lon"'\nlink: \u0027\u0027\nimmagine: \u0027'"$_attachments"'\u0027\ndata: '"$data"'\n</yamldata></pre>", "labels": ["form"] }' https://api.github.com/repos/emergenzeHack/italiaafuoco_segnalazioni/issues
		done < $INPUT
		IFS=$OLDIFS

		#creo copia del trigger e dell'attuale file di confronto
		cp "$cartella/data/trigger.csv" "$cartella/data/triggertmp.csv"
		cp "$cartella/data/compare.csv" "$cartella/data/compareCopy.csv"
		
		# uso copia del trigger e dell'attuale file di confronto per estrarre i record nuovi da aggiungere al file di confronto
		/usr/local/bin/csvsql --no-inference --query "select * from 'triggertmp' where id NOT IN (select id  from 'compareCopy') order by id" "$cartella/data/triggertmp.csv" "$cartella/data/compareCopy.csv" > "$cartella/data/notInCompare.csv"
		
		# aggiungo i nuovi record triggerati al file compare in copia e creo nuovo compare
		/usr/local/bin/csvstack "$cartella/data/notInCompare.csv" "$cartella/data/compareCopy.csv" > "$cartella/data/compare.csv"
		

    fi

fi
