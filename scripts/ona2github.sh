#!/bin/bash

cartella="/var/nadir/andrea/script/progetti/emergenzaAbruzzo"
web="/var/www/nadir/wordpress/static/projs/emergenzaAbruzzo"

# verifico la risposta del server
code=$(curl -s -o /dev/null -w "%{http_code}" -X GET https://api.ona.io/api/v1/data/175957 -u aborruso:laMiaPassword)

if [ $code -eq 200 ]
then

    #creo un file per fare il confronto tra i nuovi dati e i vecchi, sarà vuoto al primo download
    file="$cartella/compare.csv"
    if [ -f "$file" ]
        then
            echo "ciao"
        else
            cp "$cartella/compare.txt" "$cartella/compare.csv"
    fi

    # scarico il file
    curl -X GET https://api.ona.io/api/v1/data/175957 -u aborruso:laMiaPassword > "$cartella/01abruzzo.json"

    # modifico il json
    cat "$cartella/01abruzzo.json" | sed 's/seg1/Accessibile a mezzi pesanti/g ; s/seg2/Accessibile ad auto/g ; s/seg3/Accessibile a fuoristrada/g ; s/seg4/Accessibile a piedi/g ; s/seg5/Non accessibile/g ; s/tip1/Mezzi spazzaneve/g ; s/tip2/Viveri/g ; s/tip3/Coperte/g ; s/tip4/Assistenza sanitaria/g'| jq '[.[]|{"lat":(if (."emergenza_widgets/posizione"  == null) then null else ."emergenza_widgets/posizione"|split(" ")[0] end),"lon":(if (."emergenza_widgets/posizione"  == null) then null else ."emergenza_widgets/posizione"|split(" ")[1] end),"latStrada":(if (."strada_widgets/geostrada"  == null) then null else ."strada_widgets/geostrada"|split(" ")[0] end),"lonStrada":(if (."strada_widgets/geostrada"  == null) then null else ."strada_widgets/geostrada"|split(" ")[1] end),"instanceID":."meta/instanceID","indirizzo":."emergenza_widgets/indirizzo","necessita":."emergenza_widgets/necessita","cellulare":."cellulare","comune":."emergenza_widgets/comune","posizione":."emergenza_widgets/posizione","notastrada":."strada_widgets/notastrada","geostrada":."strada_widgets/geostrada","_uuid":."_uuid","email":."anagrafica_widgets/email","provincia":."emergenza_widgets/provincia","foto":."emergenza_widgets/foto","_submission_time":."_submission_time","accesso":."emergenza_widgets/accesso","_attachments":("https://api.ona.io"+._attachments[0].download_url),"nota":."emergenza_widgets/nota","nome":."anagrafica_widgets/nome","id":."_id"}]' > "$cartella/02abruzzo.json"

    # creo CSV
    cat "$cartella/02abruzzo.json" | in2csv -f json | sed 's/https:\/\/api.ona.io,/,/g'> "$cartella/03abruzzo.csv"

    # recupero il nome delle province
    /usr/local/bin/csvsql --no-inference --query "select '03abruzzo'.*,'province'.'nomeProvincia' from '03abruzzo' LEFT JOIN 'province' ON ('03abruzzo'.'provincia' = 'province'.'idProvincia')" "$cartella/03abruzzo.csv" "$cartella/data/province.csv" > "$cartella/04abruzzo.csv"

    # recupero il nome dei comuni
    /usr/local/bin/csvsql --no-inference --query "select '04abruzzo'.*,'comuni'.'nomeComune' from '04abruzzo' LEFT JOIN 'comuni' ON ('04abruzzo'.'comune' = 'comuni'.'idComune')" "$cartella/04abruzzo.csv" "$cartella/data/comuni.csv" > "$cartella/05abruzzo.csv"

    # estraggo solo i record già non presenti in archivio. Li ordino per ID, in modo che esca per primo su Telegram il messaggio più vecchio
    /usr/local/bin/csvsql --no-inference --query "select * from '05abruzzo' where id NOT IN (select id  from 'compare') order by id" "$cartella/05abruzzo.csv" "$cartella/compare.csv" > "$cartella/trigger.csv"

    numeroRigheCSV=$(wc -l < "$cartella/trigger.csv" )

    if [[ "$numeroRigheCSV" -gt 1 ]]; then

        # estraggo il corpo rimuovendo riga intestazione e creofile
        sed -e '1d' $cartella/trigger.csv | csvformat -D "|" > $cartella/triggerRun.csv

        INPUT="$cartella/triggerRun.csv"
                OLDIFS=$IFS
                IFS="|"
                [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
                while read lat lon latStrada lonStrada instanceID indirizzo necessita cellulare comune posizione notastrada geostrada _uuid email provincia foto _submission_time accesso _attachments nota nome id nomeProvincia nomeComune
                do
                data=$(date -d "$_submission_time" +%d/%m/%Y)
                    sleep 2
                    curl -i -H 'Authorization: token 00000IlMioToken00000' -d '{ "title": "'"$nota"'", "body": "<pre><yamldata>tel: \u0027'"$cellulare"'\u0027\nemail: '"$email"'\ndescrizione: \u0027'"$nota"'\u0027\nindirizzo: \u0027'"$indirizzo"'\u0027\nlat: '"$lat"'\nlon: '"$lon"'\nlink: \u0027\u0027\nimmagine: \u0027'"$_attachments"'\u0027\ndata: '"$data"'\nnecessita: \u0027'"$necessita"'\u0027\naccesso: \u0027'"$accesso"'\u0027\nlatStrada: '"$latStrada"'\nlonStrada: '"$lonStrada"'\nnotastrada: \u0027'"$notastrada"'\u0027\n</yamldata></pre>", "labels": ["emergenzaAbruzzo","nodo001"] }' https://api.github.com/repos/emergenzeHack/terremotocentro_segnalazioni/issues
                done < $INPUT
                IFS=$OLDIFS

        #creo copia del trigger e dell'attuale file di confronto
        cp "$cartella/trigger.csv" "$cartella/triggertmp.csv"
        cp "$cartella/compare.csv" "$cartella/compareCopy.csv"

        # uso copia del trigger e dell'attuale file di confronto per estrarre i record nuovi da aggiungere al file di confronto
        /usr/local/bin/csvsql --no-inference --query "select * from 'triggertmp' where id NOT IN (select id  from 'compareCopy') order by id" "$cartella/triggertmp.csv" "$cartella/compareCopy.csv" > "$cartella/notInCompare.csv"

        # aggiungo i nuovi record triggerati al file compare in copia e creo nuovo compare
        /usr/local/bin/csvstack "$cartella/notInCompare.csv" "$cartella/compareCopy.csv" > "$cartella/compare.csv"

        # creo copia del file di archivio e la espongo sul web
        #cp "$cartella/compare.csv" "$web/compare.csv"
        /usr/local/bin/csvsql --no-inference --query "select * from 'compare' where lat > 0 AND lon > 0 order by id desc" "$cartella/compare.csv" >  "$web/geoCompare.csv"
        /usr/local/bin/csvsql --no-inference --query "select * from 'compare' order by id desc" "$cartella/compare.csv" >  "$web/compare.csv"

    fi

fi
