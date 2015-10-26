#!/bin/bash
tool=/home/14/ishikawa/script/Bench_test/tools
list=parms/bg.list
dir=/WORK14/ishikawa/IEEE/Test/vad_new/MFCC38A2.0DEV/log
com=oracle

#ls ${dir}

for file in `cat parms/list`
do
    #perl ${tool}/labels_m2x.pl -h
    echo ${file}.${com}
    perl ${tool}/labels_m2x.pl -in ${dir} -list $list -com ${com} -num ${file}.${com} -type 1 -csv log.csv -ma 19 -best
    #less log.csv
    break
done
