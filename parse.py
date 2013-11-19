import sys
from collections import OrderedDict
dic = OrderedDict()
with open(sys.argv[1]) as f:
    for line in f:
        key = tuple(tuple(x.split(',')) 
	for x in line.split())
        rev_key = tuple(x[::-1] for x in key)
        if key not in dic and rev_key not in dic:
            dic[key] = line.strip()

for v in dic.itervalues():
    print v

