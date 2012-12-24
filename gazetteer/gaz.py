#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import codecs
from marisa_trie import Trie

reload(sys)
sys.setdefaultencoding('utf8')

perfile = open(os.path.dirname(os.path.realpath(__file__)) + '/NE.PER.lex')
locfile = open(os.path.dirname(os.path.realpath(__file__)) + '/NE.LOC.lex')
orgfile = open(os.path.dirname(os.path.realpath(__file__)) + '/NE.ORG.lex')

perlines = perfile.readlines()
pers = map(lambda s: s.split()[0], perlines)
loclines = locfile.readlines()
locs = map(lambda s: s.split()[0], loclines)
orglines = orgfile.readlines()
orgs = map(lambda s: s.split()[0], orglines)

pers = [s for s in pers if len(s)>6]
locs = [s for s in locs if len(s)>6]
#orgs = [s for s in orgs if len(s)>6]

per_trie = Trie(pers)
loc_trie = Trie(locs)
org_trie = Trie(orgs)

#inputfile = open('../db/GazetteResult_1_950.txt')
#f = codecs.open('GazResult_1_950.txt','w','utf-8')
inputfile = open(sys.argv[1])
f = codecs.open(sys.argv[2],'w','utf-8')
lines = inputfile.readlines()
lines = map(lambda s: s.strip(), lines)
words = map(lambda s: s.split()[0], lines)

i = 0
while i < len(lines):
    ss = unicode(words[i])
    j = i

    if ss in org_trie:
        while ss in org_trie:
            j += 1
            if j>=len(words):
                break
            ss += words[j]
        parts = lines[i].split()

        for part in parts[:-1]:
            print >>f, part.encode('utf-8'),
        print >> f, 'B-InORGGazetteer', parts[-1].encode('utf-8')

        for k in range(i+1,j):
            parts = lines[k].split()
            for part in parts[:-1]:
                print >>f, part.encode('utf-8'),
            print >> f, 'I-InORGGazetteer', parts[-1].encode('utf-8')
        i = j
        continue

    if ss in per_trie:
        while ss in per_trie:
            j += 1
            if j>=len(words):
                break
            ss += words[j]
        parts = lines[i].split()

        for part in parts[:-1]:
            print >>f, part.encode('utf-8'),
        print >> f, 'B-InPERGazetteer', parts[-1].encode('utf-8')

        for k in range(i+1,j):
            parts = lines[k].split()
            for part in parts[:-1]:
                print >>f, part.encode('utf-8'),
            print >> f, 'I-InPERGazetteer', parts[-1].encode('utf-8')
        i = j
        continue

    if ss in loc_trie:
        while ss in loc_trie:
            j += 1
            if j>=len(words):
                break
            ss += words[j]
        parts = lines[i].split()

        for part in parts[:-1]:
            print >>f, part.encode('utf-8'),
        print >> f, 'B-InLOCGazetteer', parts[-1].encode('utf-8')

        for k in range(i+1,j):
            parts = lines[k].split()
            for part in parts[:-1]:
                print >>f, part.encode('utf-8'),
            print >> f, 'I-InLOCGazetteer', parts[-1].encode('utf-8')
        i = j
        continue

    parts = lines[i].split()
    for part in parts[:-1]:
        print >>f, part.encode('utf-8'),
    print >> f, 'O', parts[-1].encode('utf-8')
    i += 1
