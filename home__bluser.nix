{ config, pkgs, ...}:

{
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./applications/sway.nix
    ./applications/waybar.nix
    ./applications/vscode.nix
    ./applications/kitty.nix
    ./applications/thunar__home.nix
    ./applications/firefox.nix
    ./applications/conky.nix
    ./applications/bash.nix
    ./applications/obs-studio.nix
    ./applications/virtual.nix
  ];
  home.packages = with pkgs; [
    # System Applications
    ark # Archive Manager
    chkrootkit # Rootkit Checker
    clamav # Antivirus
    clamtk # Antivirus GUI
    cpuid # Hardware Monitor
    curl # Web Interactor
    dolphin # File Manager
    git # Version Control
    gparted # Storage Partitioning Tool
    htop # Interactive Process Viewer
    jq # JSON Query Tool
    keepass # Password Manager
    krusader # File Manager
    meld # File Diff Tool Visualiser
    nethogs # Network Process Viewer
    networkmanager-openvpn # OpenVPN Network Manager plugin
    networkmanagerapplet # Network Manager Applet
    ntp # Date/Time Synchroniser
    onboard # On Screen Keyboard
    openvpn # VPN Client
    p7zip # File Compression
    pavucontrol # Virtual Audio Controls
    python3 # Python IDE
    remmina # Remote Access client
    file-rename # Perl Renaming file tool
    screen # Persistent Background Terminal
    speedtest-cli # Command Line Internet Speedtest
    xfce.thunar # File Manager
    wget # Web Interactor
    zsh # Z Shell

    # Internet Applications
    google-chrome # Chrome based Web Browser
    discord # Instant Messenger
    element-desktop # Secure Instant Messenger
    lynx # Command Line Web Broswer
    thunderbird # Email Client

    # Media Applications
    audacity # Audio Editor
    blender # 3D Animation
    darktable # RAW Image editor
    davinci-resolve # Video Editor
    ffmpeg # Video Encoder
    handbrake # Video Encoder
    krita # Image Editor
    libcamera # Web Cam Stack for Linux
    exiftool # Read/Write EXIF Metadata Tool
    libmkv # Video Encoder
    mediainfo-gui # Display media meta data
    qimgv # Image Viewer
    strawberry # Music Player
    vlc # Video Player

    # Office Applications
    (calibre.override{ unrarSupport = true;}) # Book Library and Document Viewer including CBR enablements
    #exodus # Crypto Wallet (Failing to build)
    foliate # Ebook Reader
    libreoffice # Document Editors

    # Python Packages
    python312Packages.yt-dlp # Download VoDs
  ];
}
