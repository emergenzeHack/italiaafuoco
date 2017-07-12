#!/bin/bash

nomeprogetto="italiaafuoco"
cartella="."
dataurlONA="https://api.ona.io/api/v1/data/220242"
usernameONA="emergenzehack"
passwordONA="emergenzehack"
tokenGithub="bad86be9f1003ceec7e6967073b3b84eea6ce4de"


# verifico la risposta del server
code=$(curl -s -o /dev/null -w "%{http_code}" -X GET $dataurlONA -u $usernameONA:$passwordONA)

if [ $code -eq 200 ]
then

    #creo un file per fare il confronto tra i nuovi dati e i vecchi, sarà vuoto al primo download
    file="$cartella/compare.csv"
    if [ -f "$file" ]
        then
            echo "file vuoto"
        else
            cp "$cartella/compare.txt" "$cartella/compare.csv"
    fi

    # scarico il file
    curl -X GET $dataurlONA -u $usernameONA:$passwordONA > "$cartella/01$nomeprogetto.json"

    # creo CSV
    cat "$cartella/01$nomeprogetto.json" | in2csv -f json | sed 's/https:\/\/api.ona.io,/,/g'> "$cartella/02$nomeprogetto.csv"

    # estraggo solo i record non presenti in archivio. Li ordino per ID, in modo che sia primo il messaggio più vecchio
    /usr/local/bin/csvsql --no-inference --query "select * from '02$nomeprogetto' where id NOT IN (select id  from 'compare') order by id" "$cartella/02$nomeprogetto.csv" "$cartella/compare.csv" > "$cartella/trigger.csv"

    numeroRigheCSV=$(wc -l < "$cartella/trigger.csv" )

    if [[ "$numeroRigheCSV" -gt 1 ]]; then

        # estraggo il corpo e creofile
        sed -e $cartella/trigger.csv | csvformat -D "|" > $cartella/triggerRun.csv

        INPUT="$cartella/triggerRun.csv"
                OLDIFS=$IFS
                IFS="|"
                [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
                read -a headers
                while read -a line; do
                  data=$(date -d "$_submission_time" +%d/%m/%Y)
                    sleep 2
                    for i in "${!line[@]}"; do
                      curl -i -H 'Authorization: token $tokenGithub' -d '{ "title": "'"${line[1]}"'", "body": "<pre><yamldata>${headers[i]}: '\u0027\n'"${line[i]}"\n</yamldata></pre>", "labels": [$nomeprogetto] }' https://api.github.com/repos/emergenzeHack/italiaafuoco_segnalazioni/issues
                  done < $INPUT
                done
        IFS=$OLDIFS

    fi

fi
