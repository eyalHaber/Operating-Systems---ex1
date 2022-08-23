#!/bin/bash
#Eyal Haber 203786298

if [[ -z $1 || -z $2 ]] # 2 arguments haven't been given
then
  echo  "Not enough parameters"
  exit 0
else # 2 arguments have been given
  dirName=$1
  wordToFind=$2
fi

# enter into the given dir:
cd $dirName

# delete all .out files:
if [[ $3 == "-r" ]] # 2 arguments haven't been given
then
  find -name "*.out" -type f -delete # in all sub dirs
else
  find -maxdepth 1 -name "*.out" -type f -delete # only in current dir
fi

# compile .c files that contain the given word:
for fileName in $(grep $3 -wils $wordToFind * *.c)
do
  gcc -w $fileName -o ${fileName%.c}.out
done





