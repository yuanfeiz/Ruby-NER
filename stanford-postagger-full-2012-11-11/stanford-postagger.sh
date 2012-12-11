#!/bin/sh
#
# usage: ./stanford-postagger.sh model textFile
#  e.g., ./stanford-postagger.sh models/left3words-wsj-0-18.tagger sample-input.txt

BASEDIR=$(dirname $0)
java -mx300m -cp "$BASEDIR/stanford-postagger.jar:" edu.stanford.nlp.tagger.maxent.MaxentTagger -model $1 -textFile $2
