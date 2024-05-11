#!/bin/bash

echo -e "Start sorting"

# try creat folders and clean
mkdir -p input_images
mkdir -p sorted_images
rm -rf input_images/* sorted_images/*

# copying media files to input_images folder
cp *.{JPG,PNG,JPEG,GIF,jpg,jpeg,png,gif} input_images 2> /dev/null

# open input_images folder
cd input_images

# delete spaces in name of files
for file in *
do
    mv "$file" "$(echo $file | sed 's/ /_/g')" 2> /dev/null
done

# extract file names with date sort and save it to file_name array
file_name=$(exiftool -fileOrder DateTimeOriginal * |\
grep "File Name" | awk '{print $4}')
file_name=($file_name)

# extract image dates with date sort and save it to file_date array
file_date=$(exiftool -fileOrder DateTimeOriginal * |\
grep "Date/Time Original" | awk '{print $4"-"$5}')
file_date=($file_date)

# debug
echo "- - - - - - - - - - - - 
File name and file date
- - - - - - - - - - - -"
i=0
for name in ${file_name[@]}
do
    echo -e "$name \t ${file_date[i]}"
    ((i++))
done

i=0
j=0 # name extencer
for name in ${file_name[@]}
do
    new_name="../sorted_images/${file_date[i]}.${name#*.}"

    # check if there is name duplicates
    while [ -f $new_name ]
    do
        ((j++))
        new_name="../sorted_images/${file_date[i]}-$j.${name#*.}"
    done
    j=0

    cp $name $new_name
    ((i++))
done

echo -e "\nComplited!"
