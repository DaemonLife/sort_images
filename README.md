# Description
This script sort images by DateTimeOriginal (shoot date) with renaming files. For example you have "DSC04586.jpg" file and output it as YYYY:MM:DD-HH:MM:SS - "2024:05:08-17:45:19.jpg".

# Preinstallation
## Fedora
```
sudo dnf install perl-Image-ExifTool
```
## Arch and Manjaro
```
sudo pacman -Syu perl-image-exiftool
```
# Running
Copy script to folder with your images (make backups!). Add permisions for running:
```
chmod +x photo_sorter.sh
```
And run:
```
./photo_sorter.sh
```
