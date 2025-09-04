{ config, pkgs, inputs, ...}:

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
  {
    programs = {
      firefox = {
        enable = true;
        #languagePacks = [ "en-GB" "ko" ];

        profiles = {
          bluser = {
            id = 0;
            name = "bluser";
            isDefault = true;
            settings = {
              "browser.search.defaultenginename" = "DuckDuckGo";
              "browser.search.order.1" = "DuckDuckGo";
              "signon.rememberSignons" = false;
              "broswer.compactmode.show" = true;
              "sidebar.main.tools" = "aichat,syncedtabs,history,bookmarks";
              "sidebar.revamp" = true;
              "sidebar.verticalTabs" = true;
              "browser.startup.page" = 3;
              "browser.download.dir" = "/mnt/InProgress/Regular_Files/Downloads";
              "media.videocontrols.picture-in-picture.video-togggle.enabled" = true;
              "browser.ml.chat.enabled" = true;
              "browser.ml.chat.sidebar" = true;
              "browser.ml.chat.provider" = "https://duckduckgo.com/?q=DuckDuckGo&ia=chat&atb=v428-1";
              "layout.css.prefers-color-scheme.content-override" = 0;
            };
            search = {
              force = true;
              default = "DuckDuckGo";
              order = [ "DuckDuckGo" ];
            };
          };
        };

        # POLICIES
        # Check about:policies#documentation for options.
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          #DisableFirefoxAccounts = true;
          #DisableAccounts = true;
          #DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "always"; # alternatives: "newtab" or "never"
          DisplayMenuBar = "default-off"; # alternatives: "always, "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"

          # EXTENSIONS
          # Check about:support for extension/add-on ID strings
          # Valid strings for installation_mode are "allowed", "blocked", "force_installed" or "normal_installed"
          ExtensionSettings = {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified
            # Black Theme:
            "{9b84b6b4-07c4-4b4b-ba21-394d86f6e9ee}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/black21/latest.xpi";
                installation_mode = "force_installed";
            };
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
            };
            # Dark Reader:
            "addon@darkreader.org" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
                installation_mode = "force_installed";
            };
            # Firefox Multi-Account Containers:
            "@testpilot-containers" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
                installation_mode = "force_installed";
            };
            # Twitch Live:
            "{55d8b663-ebee-46e9-886b-2539b1ebc9c7}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/twitch-live-for-firefox/latest.xpi";
                installation_mode = "force_installed";
            };
            # Star Citizen Hangar XPLORer:
            "HangarXPLOR@ddrit.com" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/star-citizen-hangar-xplorer/latest.xpi";
                installation_mode = "force_installed";
            };
            # ptYou - Star Citizen Contact Manager:
            "ptYou@ddrit.com" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ptyou/latest.xpi";
                installation_mode = "force_installed";
            };
            # Twitch Auto Claim:
            "{631d447a-17e8-43af-b541-3bf88cb55800}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/twitch-auto-claim/latest.xpi";
                installation_mode = "force_installed";
            };
            # BetterTTV:
            "firefox@betterttv.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/betterttv/latest.xpi";
                installation_mode = "force_installed";
            };
            # DuckDuckGo Privacy Essentials:
            "jid1-ZAdIEUB7XOzOJw@jetpack" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
                installation_mode = "force_installed";
            };
            # Beyond 20:
            "beyond20@kakaroto.homelinux.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/beyond-20/latest.xpi";
                installation_mode = "force_installed";
            };
            # Fox Clocks:
            "{d37dc5d0-431d-44e5-8c91-49419370caa1}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxclocks/latest.xpi";
                installation_mode = "force_installed";
            };
            # NoScript:
            "{73a6fe31-595d-460b-a920-fcc0f8843232}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/noscript/latest.xpi";
                installation_mode = "force_installed";
            };
            # Rain Alarm Extension:
            "rain-alarm@mdiener.de" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/rain-alarm-extension/latest.xpi";
                installation_mode = "force_installed";
            };
            # Reddit Enhancement Suite:
            "jid1-xUfzOsOFlzSOXg@jetpack" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
                installation_mode = "force_installed";
            };
            # Tree Style Tab:
            "treestyletab@piro.sakura.ne.jp" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
                installation_mode = "force_installed";
            };
            # Trilium Web Clipper:
            "{1410742d-b377-40e7-a9db-63dc9c6ec99c}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
                installation_mode = "force_installed";
            };
            # Cookiebro:
            "{15b1b2af-e84a-4c70-ac7c-5608b8eeed5a}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/cookiebro/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # Download Star:
            "{8cc0b007-e40b-46e8-9e50-e3bf021c94ab}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/download-star/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # Greasemonkey:
            "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/greasemonkey/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # Owlbear Rodeo Tracker:
            "{d406cfb1-c5aa-4d94-b4b1-0bf49a700dae}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/owlbear-combat-tracker/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # RESTED:
            "rested@restedclient" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/rested/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # TorGuard VPN Extension:
            "@VPNetworksLLC" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/vpnetworks-proxy/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # Stylish - Custom themese for any websites:
            "{46551EC9-40F0-4e47-8E18-8E5CF550CFB8}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/stylish/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
            # Web Developer:
            "{c45c406e-ab73-11d8be73-000a95be3b12}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/web-developer/latest.xpi";
                installation_mode = "normal_installed";
                enabled = false;
            };
          };
          # PREFERENCES
          # Check about:config for options
          Preferences = {
            "browswer.contentblocking.category" = {
                Value = "strict";
                Status = "locked";
            };
            "extensions.pocket.enabled" = lock-false;
            #"extensions.screenshots.disabled" = lock-true;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "broswer.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "broswer.urlbar.showSearchSuggestionsFirst" = lock-false;
            "broswer.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
            "broswer.newtabpage.activity-stream.feeds.snippets" = lock-false;
            "broswer.newtabpage.activity-stream.section.hightlights.includePocket" = lock-false;
            #"broswer.newtabpage.activity-stream.section.hightlights.includeBookmarks" = lock-false;
            #"broswer.newtabpage.activity-stream.section.hightlights.includeDownloads" = lock-false;
            "broswer.newtabpage.activity-stream.section.hightlights.includeVisited" = lock-false;
            "broswer.newtabpage.activity-stream.showSponsored" = lock-false;
            "broswer.newtabpage.activity-stream.system.showSponsored" = lock-false;
            "broswer.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          };
        };
      };
    };    
  }