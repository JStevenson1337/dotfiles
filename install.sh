#!/usr/bin/env bash

# Update and Upgrade Packages
sudo bash -c 'for i in update {,dist-}upgrade auto{remove,clean}; do apt-get $i -y; done'

# Check for the provided file and process it
packages="$1"
if [[ -f "$packages" ]]; then
    while read -r line; do
        echo "$line" | grep -E 'autoclean' --context=5
    done < "$packages"
else
    echo "Error: File $packages does not exist."
    exit 1
fi

printf "\n\n\n\t\t\t\tUpdate Successful\n"

# Define an array of common RC files
rc_files=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.profile"
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.tmux.conf"
    "$HOME/.tmux.conf.local"
    "$HOME/.gitconfig"
    "$HOME/.inputrc"
    "$HOME/.emacs.d/init.el"
    "$HOME/.authinfo.gpg"
    "$HOME/.bash_history"
)

# Define an array of folders and additional files to back up
conf_dirs=(
    "$HOME/.ssh"
    "$HOME/.vscode"
    "$HOME/ohmyzsh"
    "$HOME/.config/Code"
    "$HOME/.config/lsp-plugins"
    "$HOME/Fira_Code_v6.2.zip"
    "$HOME/.emacs.d"
    "$HOME/.wakatime"
    "$HOME/.tmux"
)

# Define the backup directories
runconf_dir="$HOME/.runconf"
conf_dirs_backup="$HOME/confdirs"
org_files_backup="$HOME/Projects/Code/OrgFiles"

# Create the backup directories if they don't exist
mkdir -p "$runconf_dir"
mkdir -p "$conf_dirs_backup"
mkdir -p "$org_files_backup"

# Backup and symlink RC files
for file in "${rc_files[@]}"; do
    if [[ -f "$file" ]]; then
        mv "$file" "$runconf_dir"
        ln -s "$runconf_dir/$(basename "$file")" "$file"
        echo "Moved $file to $runconf_dir and created symlink"
    else
        echo "File $file does not exist, skipping..."
    fi
done

# Backup and symlink configuration directories and additional files
for dir in "${conf_dirs[@]}"; do
    if [[ -e "$dir" ]]; then
        mv "$dir" "$conf_dirs_backup"
        ln -s "$conf_dirs_backup/$(basename "$dir")" "$dir"
        echo "Moved $dir to $conf_dirs_backup and created symlink"
    else
        echo "Directory or file $dir does not exist, skipping..."
    fi
done

# Recursively search for .org files in $HOME/Projects and move them to $org_files_backup
find "$HOME/Projects" -type f -name "*.org" -exec mv {} "$org_files_backup" \;
echo "Moved all .org files to $org_files_backup"

# Encrypt the backup directories
gpg_recipient="DCC2C3D389236A2485CC515339328501C8FF50EB"

tar -czf "$runconf_dir.tar.gz" -C "$HOME" "$(basename "$runconf_dir")"
tar -czf "$conf_dirs_backup.tar.gz" -C "$HOME" "$(basename "$conf_dirs_backup")"
tar -czf "$org_files_backup.tar.gz" -C "$HOME/Projects/Code" "$(basename "$org_files_backup")"

gpg --encrypt --recipient "$gpg_recipient" "$runconf_dir.tar.gz"
gpg --encrypt --recipient "$gpg_recipient" "$conf_dirs_backup.tar.gz"
gpg --encrypt --recipient "$gpg_recipient" "$org_files_backup.tar.gz"

# Clean up unencrypted tar files
rm "$runconf_dir.tar.gz" "$conf_dirs_backup.tar.gz" "$org_files_backup.tar.gz"

echo "Backup, symlink, and encryption process completed."
