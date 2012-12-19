from __future__ import division
import sys
from collections import defaultdict

resfile = open(sys.argv[1])

res = resfile.readlines()
res = map(lambda s: s.strip(), res)

guessCount = defaultdict(int)
goldCount = defaultdict(int)
correct = defaultdict(int)

for line in res:
    words = line.split()
    if len(words) == 0:
        continue

    word = words[0]
    words = words[-2:]
    if len(words[0]) > 2:
        gold = words[0][2:]
    else:
        gold = words[0]
    if len(words[1]) > 2:
        guess = words[1][2:]
    else:
        guess = words[1]

    if (gold != 'O'):
        goldCount[gold] += len(word)//3

    if (guess != 'O'):
        guessCount[guess] += len(word)//3

        if (gold == guess):
            correct[guess] += len(word)//3
    
all_correct = 0
all_gold = 0
all_guess = 0
for key in correct.keys():
    print 'Precision: ', key, correct[key], '/', guessCount[key],'=',correct[key]/guessCount[key]
    print 'Recall: ', key, correct[key], '/', goldCount[key],'=',correct[key]/goldCount[key]
    pre = correct[key]/guessCount[key]
    rec = correct[key]/goldCount[key]
    print 'F1-Score: ', key, 2*pre*rec/(pre+rec)

    all_correct += correct[key]
    all_gold += goldCount[key]
    all_guess += guessCount[key]

print 'Overall Precision: ', all_correct, '/', all_guess,'=',all_correct/all_guess
print 'Overall Recall: ', all_correct, '/', all_gold,'=',all_correct/all_gold
pre = all_correct/all_guess
rec = all_correct/all_gold
print 'Overall F1-Score: ', 2*pre*rec/(pre+rec)
