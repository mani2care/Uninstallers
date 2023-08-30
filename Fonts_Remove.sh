#!/bin/bash

# Specify the directory containing the fonts
font_directory="/Library/Fonts/test"

# List all fonts in the specified directory
font_list=$(ls "$font_directory") #bulk or list out from the path
#font_list=("ABBvoice-Regular.ttf" "ABBvoice-Bold.ttf" "ABBvoice-Italic.ttf") #mention the font name if you have specifically 

# Loop through each font file in the directory
for font_file in $font_list; do
    # Check if the font file name starts with "ABBvoice"
    if [[ "$font_file" == "ABBvoice"* ]]; then
        # Remove the font file
        sudo rm "$font_directory/$font_file"
        echo "Removed font: $font_file"
    fi
done

echo "Font removal process completed."
