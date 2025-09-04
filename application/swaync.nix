{ config, pkgs, ...}:

{
    services.swaync = {
        enable = true;
        settings = {
            # Options can be found https://github.com/ErikReider/SwayNotificationCentre/blob/main/src/configSchema.json
            positionX = "right";
            positionY = "top";
            layer = "overlay";
            control-center-layer = "top";
            layer-shell = true;
            cssPriority = "application";
            control-centre-margin-top = 0;
            control-centre-margin-bottom = 0;
            control-centre-margin-right = 0;
            control-centre-margin-left = 0;
            notification-2fa-action = true;
            notification-inline-replies = false;
            notification-icon-size = 64;
            notification-body-image-height = 100;
            notification-body-image-width = 200;
        };
    };
}