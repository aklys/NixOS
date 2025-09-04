{ config, pkgs, ...}:

let
  watairTheme = pkgs.writeTextDir {
    name = "Watair";
    text = ''
      theme.conf = ""
        [Theme]
        Name=Watair
      "";
      main.qml = ""
        import QtQuick 2.0
        import QtQuick.Controls 2.0
        
        Item {
          width: 1920
          height: 1080
          
          Rectangle {
            anchors.fill: parent
            color: "black"
            
            Text {
              anchors.centerIn: parent
              text: "Weclome"
              color: "white"
              font.pixelSize: 48
            }
          }
        }
      "";
    '';
  };

in

{
  services.displayManager = {
    sessionPackages = [ pkgs.sway ];
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "Watair";
    };
  };
}
