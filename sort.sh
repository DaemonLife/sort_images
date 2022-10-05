#!/bin/bash

# delete spaces in name of files
for file in *
do
    mv "$file" "$(echo $file | sed 's/ /_/g')" 2> /dev/null 
done

~/Documents/exiftool/exiftool -fileOrder DateTimeOriginal * | grep "File Name" > temp

file=$(cat temp)
rm -rf temp

for line in $file
do
    echo "$line" | grep ".JPG\|.PNG\|.jpg\|.jpeg\|.JPEG\|.png\|.gif\|.GIF" >> temp
done

file=$(cat temp)
rm -rf temp

i=1
mkdir new
for line in $file
do
    cp $line new/$i.${line#*.}
    ((i++))
done
