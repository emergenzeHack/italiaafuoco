#!/bin/bash

nomeprogetto="italiaafuoco"
cartella=$(pwd)/..
source "$cartella"/anagrafica.txt

# abilito debug
set -x


# verifico la risposta del server
code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$dataurlONA" -u "$usernameONA":"$passwordONA")

if [ $code -eq 200 ]
then

    #creo un file per fare il confronto tra i nuovi dati e i vecchi, vuoto al primo download
<<comment1    
	file="$cartella/compare.csv"
    if [ -f "$file" ]
        then
            echo "file vuoto"
        else
            cp "$cartella/compare.txt" "$cartella/compare.csv"
    fi
comment1

    # scarico il file
    curl -X GET $dataurlONA -u $usernameONA:$passwordONA > "$cartella"/data/01$nomeprogetto.json

    # creo CSV
    cat "$cartella"/data/01$nomeprogetto.json | in2csv -f json | sed 's/https:\/\/api.ona.io,/,/g'> "$cartella"/data/02$nomeprogetto.csv

    # estraggo solo i record non presenti in archivio. Li ordino per ID, in modo che sia primo il messaggio più vecchio
    #csvsql --no-inference --query "select * from '02$nomeprogetto' where id NOT IN (select id  from 'compare') order by id" "$cartella/02$nomeprogetto.csv" "$cartella/compare.csv" > "$cartella/trigger.csv"

    #numeroRigheCSV=$(wc -l < "$cartella/trigger.csv" )

    if [[ 2 -gt 1 ]]; then
        # estraggo il corpo e creofile
        #sed -e $cartella/trigger.csv | csvformat -D "|" > $cartella/triggerRun.csv

		INPUT="$cartella/data/triggerRun.csv"
		OLDIFS=$IFS
		IFS="|"
		[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
		while read lat lon latStrada lonStrada instanceID indirizzo necessita cellulare comune posizione notastrada geostrada _uuid email provincia foto _submission_time accesso _attachments nota nome id nomeProvincia nomeComune
		do
		data=$(date -d "$_submission_time" +%d/%m/%Y)
			sleep 2
			curl -i -H 'Authorization: token '"$githubTokenExt"'' -d '{ "title": "'"$nota"'", "body": "<pre><yamldata>tel: \u0027'"$cellulare"'\u0027\nemail: '"$email"'\ndescrizione: \u0027'"$nota"'\u0027\nindirizzo: \u0027'"$indirizzo"'\u0027\nlat: '"$lat"'\nlon: '"$lon"'\nlink: \u0027\u0027\nimmagine: \u0027'"$_attachments"'\u0027\ndata: '"$data"'\nnecessita: \u0027'"$necessita"'\u0027\naccesso: \u0027'"$accesso"'\u0027\nlatStrada: '"$latStrada"'\nlonStrada: '"$lonStrada"'\nnotastrada: \u0027'"$notastrada"'\u0027\n</yamldata></pre>", "labels": ["emergenzaAbruzzo","nodo001"] }' https://api.github.com/repos/emergenzeHack/italiaafuoco_segnalazioni/issues
		done < $INPUT
		IFS=$OLDIFS

    fi

<<comment2
comment2

fi