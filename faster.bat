@echo off
echo '************************************************************************************************ : Pull:' %1
echo '************************************************************************************************ : Branch:' %2
echo '************************************************************************************************ : OrgAlias:' %3
cd C:\work\SF\Master\Jenkins
git checkout %2 && git reset --hard && git remote prune origin && git pull && (node deploy.js %1 && node copy.js && node run.js) && (rename force-app force-app++)  && (move output\* force-app)  && (sfdx force:source:convert -d mdapioutput/) && (sfdx force:mdapi:deploy -d mdapioutput/ -u  %3 -w 100)

