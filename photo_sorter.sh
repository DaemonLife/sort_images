#!/bin/bash

# fun message to terminal
message() {
    # term_line="- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    term_line="---------------------------------------------------------------------"
    term_width=70
    ln=${#1}
    left=$(( ($term_width-$ln)/2 ))
    # top - print term_line on top
    # bottom - print term_line on bottom
    # two - print two lines
    if [ "$2" == "top" ] || [ "$2" == "two" ]; then echo $term_line; fi
    if [ "$1" != "" ]; then
        # echo -e "$1" # lefted message
        echo -e "\033[${left}G$1" # centered message
    fi
    if [ "$2" == "bottom" ] || [ "$2" == "two" ]; then echo $term_line; fi
}

echo '
               PPPPPP  HH   HH  OOOOO  TTTTTTT  OOOOO  
               PP   PP HH   HH OO   OO   TTT   OO   OO 
               PPPPPP  HHHHHHH OO   OO   TTT   OO   OO 
               PP      HH   HH OO   OO   TTT   OO   OO 
               PP      HH   HH  OOOO0    TTT    OOOO0  
                                            
                                  tt                  
                sss   oooo  rr rr  tt      eee  rr rr  
               s     oo  oo rrr  r tttt  ee   e rrr  r 
                sss  oo  oo rr     tt    eeeee  rr     
                   s  oooo  rr      tttt  eeeee rr     
                sss                                    
'
message "GitHub: https://github.com/DaemonLife/sort_images"
message "Telegram: https://t.me/doriverte\n"

# try creat folders
mkdir -p input_images
mkdir -p sorted_images

# check photos exist
if [ -z "$(ls *.JPG *.PNG *.JPEG *.GIF *.jpg *.jpeg *.png *.gif 2>/dev/null)" ]; then
    cd input_images
    if [ -z "$(ls *.JPG *.PNG *.JPEG *.GIF *.jpg *.jpeg *.png *.gif 2>/dev/null)" ]; then
        message "No photos. Exit."
        exit
    else cd ..
    fi
else
    # moving media files to input_images folder
    mv *.{JPG,PNG,JPEG,GIF,jpg,jpeg,png,gif} input_images 2> /dev/null
fi

# check if there is files in sorted_images folder
if [ "$(ls -A "sorted_images" | wc -l)" -eq 0 ]; then true # pass/skip
else
    while true; do
        read -p "$(message "There are already sorted photos. Delete? (y/N): ")" yn
        case $yn in 
	        [yY] ) rm -rf sorted_images/* && break;;
	        [nN] ) break;;
	         * ) if [[ -z "$yn" ]]; then break;
                 else true #message "Invalid response!";
                 fi
        esac
    done
fi

# make backups
make_backup=true
while true; do
    read -p "$(message "Do you want to save backup in input_images folder? (Y/n): ")" yn
    case $yn in 
	    [yY] ) break;;
	    [nN] ) make_backup=false && break;;
	    * ) if [[ -z "$yn" ]]; then break; fi
    esac
done

# switch script work folder
cd input_images
# delete spaces in name of files
for file in *
do
    mv "$file" "$(echo $file | sed 's/ /_/g')" 2> /dev/null
done

# extract and store metadata
echo && message "Extract information..." bottom
raw_meta="$(exiftool -fileOrder DateTimeOriginal * | grep -E "File Name|Date/Time Original|Metadata Date")"

# dict inicialization for metadata
declare -A meta_dict
# table header
printf "%-0s %-1s %-25s %39s\n" "N" "|" "File name" "Shoot date"

message "" bottom
i=0 # lines number
# check if File name repeats in raw_meta and write NoneDate if so it is
second_file_name=false
# IFS= because I don't want separate lines by spaces, it disable IFS
ls -l
while IFS= read -r line; do
    echo $line
    if [[ $line =~ ^"File Name" ]] && [ "$second_file_name" = true ]; then
        file_date="NoneDate"
        ((i++))
        printf "%-0s %-1s %-25s %39s\n" ${i} "|" ${file_name} ${file_date}
        meta_dict[$file_name]=$file_date
        file_name=$(echo "$line" | awk '{print $4}') # print the desired column
        continue
    
    elif [[ $line =~ ^"File Name" ]]; then
        file_name=$(echo "$line" | awk '{print $4}') # print the desired column
        second_file_name=true
        continue
    elif [[ $line =~ ^"Date/Time Original" ]]; then
        file_date="$(echo "$line" | awk '{print $4"-"$5}')"
    elif [[ $line =~ ^"Metadata Date" ]]; then
        file_date="$(echo "$line" | awk '{print $4"-"$5}')-MD"     
    fi
    
    # check if there is actually a date in the metadata
    if [ "$file_date" = "" ]; then file_date="NoneDate"; fi
    ((i++))
    printf "%-0s %-1s %-25s %39s\n" ${i} "|" ${file_name} ${file_date}
    meta_dict[$file_name]=$file_date
    second_file_name=false # so date was write

done <<< "$raw_meta"

# write last file withoin date bc while by lines is done
if [ "$second_file_name" = "true" ]; then
    file_date="NoneDate"
    meta_dict[$file_name]=$file_date
    ((i++))
    printf "%-0s %-1s %-25s %39s\n" ${i} "|" ${file_name} ${file_date}
fi

# sorting
echo && message "Start sorting. Don't worry about renaming order." bottom
printf "%-0s %-1s %-25s %39s\n" "N" "|" "File name" "New name for file"
message "" bottom
i=0 # lines number
j=0 # name extencer for duplicates
for key in ${!meta_dict[@]}; do
    name=$key
    new_img_folder="../sorted_images/"
    new_name="${meta_dict[$key]}.${name#*.}"

    # check if there is name duplicates
    path="$new_img_folder$new_name"
    while [ -f $path ]
    do
        ((j++))
        new_name="${meta_dict[$key]}-$j.${name#*.}"
        path="$new_img_folder$new_name"
    done
    j=0
    # what to do with original files
    if [ "$make_backup" = "true" ]; then
        cp $name $new_img_folder$new_name
    else
        mv $name $new_img_folder$new_name
    fi
    ((i++))
    # dict in bash store own keys with random way. Keep in mind and don't worry about renaming order 
    printf "%-0s %-1s %-25s %39s\n" ${i} "|" ${name} ${new_name}
done

echo && message "Complited! New photos saved in sorted_images folder."
