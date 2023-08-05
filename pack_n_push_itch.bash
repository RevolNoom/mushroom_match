#!/bin/bash


godot4 --export-release "Android" mushroom-match.apk
butler push mushroom-match.apk revolnoom/mushroom-match:android


godot4 --export-release "Web" mushroom-match-html/index.html
cd mushroom-match-html
zip -9 mushroom-match-html *
cd ..
butler push mushroom-match-html/mushroom-match-html.zip revolnoom/mushroom-match:html
butler push mushroom-match-html/mushroom-match-html.zip revolnoom/mushroom-match:playable
