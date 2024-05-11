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
Copy script to folder with your images. Add permisions for running:
```
chmod +x sort.sh
```
And run:
```
./sort.sh
```
