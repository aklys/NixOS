{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    conky
  ];
  #services.conky = {
  #  enable = true;
  #};
  
  xdg.configFile."conky/conky.conf".text = ''
    conky.config = {
      -- Conky configuration file

      -- General Settings
      background = false,
      net_avg_samples = 2, -- The numbers of samples to average for net data
      cpu_avg_samples = 2, -- The number of samples to average for CPU monitoring
      diskio_avg_samples = 10,  -- The number of samples to average for disk I/O monitoring
      update_interval = 2, -- Visual update interval
      double_buffer = true, -- Use the Xdbe extension? (eliminated flicker)
      no_buffers = true,
      text_buffer_size = 2048,
      imlib_cache_size = 0,
      temperature_unit = 'celsius',

      -- Window Settings
      own_window = true,
      own_window_type = 'desktop', -- desktop (background), panel(bar), override
      own_window_transparent = false,
      own_window_argb_visual = true, -- turn on transparency
      own_window_argb_value = 255, -- range from 0 transparent to 255 opaque
      -- own_window_hints = 'undecorated,stick,skip_taskbar,skip_pager,below',
      draw_blended = false,
      maximum_width = 320,

      -- Placement
      alignment = 'middle_right',
      xinerama_head = 0, -- for multi monitor setups, monitor 0, 1, 2
      gap_x = 10,
      gap_y = -8,

      -- Font Settings
      use_xft = true,
      font = 'DejaVu:size=10',
      draw_shades = false, -- black shadow on text (not good if text is black)
      draw_outline = false, -- black outline around text (not good if text is black)

      -- Colors
      default_color = '#FFFFFF', -- Regular Text
      default_shade_color = '#000000',
      default_outline_color = '#000000',
      color1 = '#FFFFFF',
      color2 = 'Light Blue',
      color3 = 'Green',
      color4 = '#FFFFFF',
      color5 = '#DCDCDC',
      color6 = '#FFFFFF',
      color7 = '#FFFFFF',
      color8 = '#FFFFFF',

      -- System statistics
      gap_x = 10,
      gap_y = 10,
    };

    conky.text = [[
      ''${color3}System Information
      ''${hr 2}
      $alignc ''${color1}''${sysname} ''${kernel} ''${machine}
      Uptime $alignr''${uptime}
      Battery  $alignr''${battery_percent BAT1}%
      ''${color3}Network Details
      ''${hr 2}
      ''${if_existing /sys/class/net/wlp1s0/dev_id}$alignc''${color2}Wireless
      $alignc''${color1}''${wireless_essid wlp1s0}(''${wireless_link_qual_perc wlp1s0}%) at ''${wireless_bitrate wlp1s0}
      $alignc''${color1}IP: ''${addr wlp1s0} | GW: ''${gw_ip}
      ''${color1}Down $alignr''${downspeed wlp1s0}
      $alignc''${downspeedgraph wlp1s0 16,300}
      ''${color1}Up $alignr''${upspeed wlp1s0}
      $alignc''${upspeedgraph wlp1s0 16,300}
      ''${else}''${endif}
      ''${color3}CPU Details
      ''${hr 2}''${goto 300}''${hr 2}
      ''${color1}Temperature $alignr''${execi 10 sensors | grep 'Core 0' | awk '{print $3}' | sed 's/[^0-9.]//g'}°C
      CPU $alignr''${cpu}%
      $alignc ''${cpugraph cpu0 16,300 dedede ffffff}
      ''${if_existing /sys/devices/system/cpu/cpu0/cpufreq/base_frequency}''${cpubar cpu0 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu1/cpufreq/base_frequency}
      $alignc''${cpubar cpu1 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu2/cpufreq/base_frequency}
      $alignc''${cpubar cpu2 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu3/cpufreq/base_frequency}
      $alignc''${cpubar cpu3 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu4/cpufreq/base_frequency}
      $alignc''${cpubar cpu4 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu5/cpufreq/base_frequency}
      $alignc''${cpubar cpu5 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu6/cpufreq/base_frequency}
      $alignc''${cpubar cpu6 4,300}''${else}''${endif}''${if_existing /sys/devices/system/cpu/cpu7/cpufreq/base_frequency}
      $alignc''${cpubar cpu7 4,300}''${else}''${endif}
      ''${color3}Memory Details
      ''${hr 2}
      ''${color1}RAM $alignr''${mem}/''${memmax} 
      $alignc''${membar 4,300}
      Swap $alignr''${swap}/''${swapmax} 
      $alignc''${swapbar 4,300}
      ''${color3}Disk Details
      ''${hr 2}
      $alignc''${color2}Local Disks
      ''${color1}Read/Write$alignr''${diskio_read}/''${diskio_write}
      ''${if_mounted /}/ $alignr''${fs_free /}/''${fs_size /}
      $alignc''${fs_bar 4,300 /}''${endif}''${if_mounted /boot}
      /boot $alignr''${fs_free /boot}/''${fs_size /boot}
      $alignc''${fs_bar 4,300 /boot}''${endif}
      $alignc''${color2}Remote Storage
      ''${if_mounted /mnt/InProgress}''${color1}/mnt/InProgress $alignr''${fs_free /mnt/InProgress}/''${fs_size /mnt/InProgress}
      $alignc''${fs_bar 4,300 /mnt/InProgress}''${endif}''${if_mounted /mnt/Media}
      ''${color1}/mnt/Media $alignr''${fs_free /mnt/Media}/''${fs_size /mnt/Media}
      $alignc''${fs_bar 4,300 /mnt/Media}''${endif}
    ]];
  '';
}