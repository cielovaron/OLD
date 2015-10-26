#!/bin/bash

# 258 166 280
rm *.log test_* *.r
for pen in 258 166 280
do
	for num in 01 02 03
	do
		rec=../test/1ch/script${num}.mfc.oracle.-${pen}.rec
		log=../test/1ch/script${num}.mfc.oracle.-${pen}.log
		ref=../ref/script${num}.txt
		perl conv2htk.pl $log event.txt 
		perl log2frame.pl -i $rec -o frame.txt
		#cat frame.txt 
		perl FB.pl ${ref} frame.txt $num,-$pen >> f.r
		perl EB2.pl -in event.txt -ref ${ref} -pa $num -pb -$pen >> e.r
		rm *.txt
	done
done	