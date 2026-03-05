#!/bin/bash

echo "--- MyNotes Installer ---"

# Select Language
echo "1. English"
echo "2. Ελληνικά"
read -p "Select Language / Επιλέξτε Γλώσσα (1/2): " lang_opt

if [[ "$lang_opt" == "2" ]]; then
    inst_lang="el"
    msg_path="Δώστε τη διαδρομή για τον φάκελο σημειώσεων: "
    msg_editor="Δώστε τον επεξεργαστή κειμένου που προτιμάτε: "
    msg_config="Ρυθμίσεις:"
    msg_dir="  Φάκελος Σημειώσεων:"
    msg_def_editor="  Προεπιλεγμένος Editor:"
    msg_installing="Εγκατάσταση του myNotes στο /usr/local/bin/..."
    msg_done="Ολοκληρώθηκε! Τώρα μπορείτε να τρέξετε το 'myNotes' από το τερματικό."
else
    inst_lang="en"
    msg_path="Enter the path for your notes directory: "
    msg_editor="Enter your preferred text editor: "
    msg_config="Configuration:"
    msg_dir="  Notes Directory:"
    msg_def_editor="  Default Editor: "
    msg_installing="Installing myNotes to /usr/local/bin/..."
    msg_done="Done! You can now run 'myNotes' from your terminal."
fi

# Ask for notes directory
default_notes_dir="$HOME/my_notes"
read -e -p "$msg_path" -i "$default_notes_dir" notes_dir
# Ensure the path is expanded and has a trailing slash
notes_dir_expanded=$(eval echo "$notes_dir")
notes_dir_final="${notes_dir_expanded%/}/"

# Ask for editor
default_editor="nano"
read -e -p "$msg_editor" -i "$default_editor" editor_choice

echo
echo "$msg_config"
echo "$msg_dir $notes_dir_final"
echo "$msg_def_editor $editor_choice"
echo

# Create a temporary file to modify
temp_script=$(mktemp)
cp myNotes.sh "$temp_script"

# Use sed to replace the configuration lines
sed -i "s#my_file=\"\$HOME/Dropbox/notes/\"#my_file=\"$notes_dir_final\"#" "$temp_script"
sed -i "s#editor=\"\${EDITOR:-nano}\"#editor=\"\${EDITOR:-$editor_choice}\"#" "$temp_script"
# Set the language in the script
sed -i "s#language=\"en\"#language=\"$inst_lang\"#" "$temp_script"

echo "$msg_installing"
sudo cp "$temp_script" /usr/local/bin/myNotes
sudo chmod +x /usr/local/bin/myNotes
rm "$temp_script"

echo "$msg_done"