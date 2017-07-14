#! /bin/bash

cd italiaafuoco_segnalazioni
git clean -fxd
git reset --hard HEAD
git pull
cd ..

python italiaafuoco_segnalazioni/scripts/github2CSV.py italiaafuoco_segnalazioni/_data/issues.csv italiaafuoco_segnalazioni/_data/issuesjson.json italiaafuoco_segnalazioni/_data/issuesgeojson.json

cd italiaafuoco_segnalazioni
git add _data
#git add vittime.md
git commit -m "auto CSV update $(date -Iseconds)"
git pull --rebase
git push

git clean -fxd
git reset --hard HEAD
cd ..
