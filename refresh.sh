#!/bin/bash

# be careful while using this script. It deletes everything apart from the files below.

find . -type f ! -regex ".*/\(stanford-ner.jar\|tagger.pl\|zprocess.pl\|a.out\|super.svm\|parser.pl\|main.sh\|tagged.*\|svm-predict\|english.all.3class.distsim.crf.ser.gz\|english.all.3class.distsim.prop\|english.conll.4class.distsim.crf.ser.gz\|english.conll.4class.distsim.prop\|english.muc.7class.distsim.crf.ser.gz\|english.muc.7class.distsim.prop\|english.nowiki.3class.distsim.crf.ser.gz\|english.nowiki.3class.distsim.prop\|ReadMe - References\|refresh.sh\)" -delete


