#!/bin/bash

mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

# notebook script
cat >~/.local/bin/st-nvim-opener <<EOF
#!/bin/bash
st -n st-notebook -e nvim "\$@" &
EOF
chmod +x ~/.local/bin/st-nvim-opener

# empty script
cat >~/.local/bin/empty-opener <<EOF
#!/bin/bash
# do nothing, prevent viewing certain types of files
EOF
chmod +x ~/.local/bin/empty-opener

# archive preview script
cat >~/.local/bin/file-roller <<EOF
#!/bin/bash
st -n file-roller -e "$(cd "$(dirname "$0")" && pwd)"/archive-preview.sh "\$@" &
EOF
chmod +x ~/.local/bin/file-roller

# notebook .desktop file
cat >~/.local/share/applications/st-nvim-opener.desktop <<EOF
[Desktop Entry]
Type=Application
Name=ST Neovim Editor
Comment=Edit text files in ST terminal with Neovim
Exec=${HOME}/.local/bin/st-nvim-opener %F
Terminal=false
Categories=Utility;TextEditor;
MimeType=text/plain;text/html;text/css;text/xml;application/json;text/x-script.python;text/x-python;text/x-shellscript;text/x-c;text/x-c++;text/x-java;text/x-tex;application/javascript;inode/x-empty;
NoDisplay=true
EOF

# empty .desktop file
cat >~/.local/share/applications/empty-opener.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Empty Opener
Comment=Do not open these file types
Exec=${HOME}/.local/bin/empty-opener %F
Terminal=false
Categories=Utility;
MimeType=application/x-executable;application/x-sharedlib;application/x-pie-executable;application/octet-stream;application/x-msdownload;application/x-dosexec;
NoDisplay=true
EOF

# file-roller .desktop file
cat >~/.local/share/applications/file-roller.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Archive Preview
Comment=Preview archive contents in terminal
Exec=${HOME}/.local/bin/file-roller %F
Terminal=false
Categories=Utility;Archiving;
MimeType=application/zip;application/x-rar;application/x-7z-compressed;application/gzip;application/x-bzip2;application/x-tar;application/x-xz;
NoDisplay=true
EOF

declare -A mime_map
mime_map["st-nvim-opener.desktop"]="text/plain text/html text/css text/xml application/json text/x-python text/x-shellscript text/x-c text/x-c++ text/x-java text/x-tex application/javascript inode/x-empty application/x-php text/markdown"
mime_map["empty-opener.desktop"]="application/x-executable application/x-sharedlib application/x-pie-executable application/octet-stream application/x-msdownload application/x-dosexec"
mime_map["nsxiv.desktop"]="image/jpeg image/png image/gif image/webp image/tiff image/bmp image/svg+xml image/x-icon"
mime_map["file-roller.desktop"]="application/zip application/x-rar application/x-7z-compressed application/gzip application/x-bzip2 application/x-tar application/x-xz"
mime_map["wps-office-pdf.desktop"]="application/pdf"
mime_map["wps-office-wps.desktop"]="application/vnd.openxmlformats-officedocument.wordprocessingml.document application/msword"
mime_map["wps-office-et.desktop"]="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel"
mime_map["wps-office-wpp.desktop"]="application/vnd.openxmlformats-officedocument.presentationml.presentation application/vnd.ms-powerpoint"
mime_map["mpv.desktop"]="audio/mpeg audio/ogg audio/wav audio/flac audio/aac audio/webm video/mp4 video/x-msvideo video/quicktime video/x-matroska video/webm video/ogg"

echo "setting default applications"
for desktop_file in "${!mime_map[@]}"; do
	for mime_type in ${mime_map[$desktop_file]}; do
		xdg-mime default "$desktop_file" "$mime_type" 2>/dev/null || true
	done
done

update-desktop-database ~/.local/share/applications 2>/dev/null || true
echo "configuration complete"
