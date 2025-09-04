{ config, pkgs, ... }:

{ 
  home.packages = with pkgs; [
    xfce.thunar # GUI File Manager
    xfce.thunar-volman # Volume Manager Plugin
    xfce.thunar-archive-plugin # Archive Manager Plugin
  ];

  xdg.mime.enable = true;

  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>

      <channel name="thunar" version="1.0">
        <property name="last-view" type="string" value="ThunarDetailsView"/>
        <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_100_PERCENT"/>
        <property name="last-window-width" type="int" value="1496"/>
        <property name="last-window-height" type="int" value="935"/>
        <property name="last-window-maximized" type="bool" value="false"/>
        <property name="last-separator-position" type="int" value="170"/>
        <property name="last-splitview-separator-position" type="int" value="662"/>
        <property name="last-location-bar" type="string" value="ThunarLocationButtons"/>
        <property name="last-image-preview-visible" type="bool" value="true"/>
        <property name="last-show-hidden" type="bool" value="true"/>
        <property name="last-side-pane" type="string" value="ThunarShortcutsPane"/>
        <property name="last-details-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_38_PERCENT"/>
        <property name="last-details-view-column-widths" type="string" value="50,50,159,50,50,50,50,50,231,50,50,329,50,156"/>
        <property name="misc-single-click" type="bool" value="false"/>
        <property name="default-view" type="string" value="ThunarDetailsView"/>
        <property name="misc-thumbnail-mode" type="string" value="THUNAR_THUMBNAIL_MODE_NEVER"/>
        <property name="misc-date-style" type="string" value="THUNAR_DATE_STYLE_YYYYMMDD"/>
        <property name="misc-full-path-in-tab-title" type="bool" value="true"/>
        <property name="last-restore-tabs" type="bool" value="true"/>
        <property name="misc-transfer-use-partial" type="string" value="THUNAR_USE_PARTIAL_MODE_REMOTE"/>
        <property name="misc-transfer-verify-file" type="string" value="THUNAR_VERIFY_FILE_MODE_REMOTE"/>
        <property name="last-tabs-left" type="array">
          <value type="string" value="computer:///"/>
        </property>
        <property name="last-focused-tab-left" type="int" value="0"/>
        <property name="last-focused-tab-right" type="int" value="0"/>
        <property name="last-menubar-visible" type="bool" value="true"/>
        <property name="last-toolbar-item-order" type="string" value="0,1,2,4,5,6,7,8,9,10,11,12,13,17,16,15,3,14"/>
        <property name="last-toolbar-visible-buttons" type="string" value="0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,1,0,1"/>
        <property name="misc-show-delete-action" type="bool" value="true"/>
        <property name="last-tabs-right" type="array">
          <value type="string" value="file:///home/bluser"/>
        </property>
      </channel>
  '';
}
