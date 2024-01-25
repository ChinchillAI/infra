{ pkgs, lib, ... }:
let
  steam-app = "2394010";
in
{
  imports = [
    ./steam.nix
  ];

  users.users.palworld = {
    isSystemUser = true;
    home = "/var/lib/palworld";
    createHome = true;
    homeMode = "750";
    group = "palworld";
  };

  users.groups.palworld = { };

  environment.systemPackages = with pkgs; [
    xdg-user-dirs
  ];

  networking.firewall = {
    allowedUDPPorts = [ 8211 ];
    allowedTCPPorts = [ 8211 ];
  };

  systemd.services.palworld = {
    wantedBy = [ "multi-user.target" ];

    #wants = [ "steam@${steam-app}.service" ];
    #after = [ "steam@${steam-app}.service" ];

    path = [ pkgs.xdg-user-dirs ];

    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        "/var/lib/steam-app-${steam-app}/PalServer.sh"
        "-useperfthreads"
        "-NoAsyncLoadingThread"
        "-UseMultithreadForDS"
      ];
      Nice = "-5";
      PrivateTmp = true;
      Restart = "always";
      User = "steam";
      WorkingDirectory = "~";
    };
    environment = {
      LD_LIBRARY_PATH = "/var/lib/steam-app-${steam-app}/linux64:${pkgs.glibc}/lib";
      SteamAppId = "892970";
    };
  };
}

