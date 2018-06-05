#!/bin/bash


echo "> Getting data..."
git pull
node copy.js
node run.js
rename force-app force-app++
move output\* force-app
sfdx force:source:convert -d mdapioutput/
sfdx force:mdapi:deploy -d mdapioutput/ -u  travis -w 100
echo "> Completed dude... Have Fun"