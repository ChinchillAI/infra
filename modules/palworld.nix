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
    rcon
  ];

  networking.firewall = {
    allowedUDPPorts = [ 8211 ];
    allowedTCPPorts = [ 8211 ];
  };

  systemd.services.palworld = {
    wantedBy = [ "multi-user.target" ];

    #wants = [ "steam@${steam-app}.service" ];
    #after = [ "steam@${steam-app}.service" ];

    # Note the following files are currently non-functionally defined:
    # /var/lib/steam/.rconrc
    # /var/lib/steam-app-2394010/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini 

    path = with pkgs; [ xdg-user-dirs rcon ];

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

      # Note: rcon returns code 3 with this method for some reason
      # Not waiting for response works, but we are racing the save
      # probably replace with mcrcon when we add secret support
      ExecStop = "${pkgs.resholve.writeScript "shutdown" {
	      interpreter = "${pkgs.zsh}/bin/zsh";
	      inputs = with pkgs; [ rcon coreutils ];
	      execer = with pkgs; [ "cannot:${rcon}/bin/rcon" ];
	    } ''
	     set -x
	     rcon -s palworld -n broadcast Shutdown_sequence_initiated
	     rcon -s palworld -n broadcast Saving_game_now
	     rcon -s palworld -n broadcast Progress_after_this_point_may_be_lost
	     rcon -s palworld -n save
	     sleep 5
	     rcon -s palworld -n broadcast Shutdown_in_15_seconds
	     sleep 5
	     rcon -s palworld -n broadcast Shutdown_in_10_seconds
	     sleep 5
	     rcon -s palworld -n broadcast Shutdown_in_5_seconds
	     sleep 1
	     rcon -s palworld -n broadcast Shutdown_in_4_seconds
	     sleep 1
	     rcon -s palworld -n broadcast Shutdown_in_3_seconds
	     sleep 1
	     rcon -s palworld -n broadcast Shutdown_in_2_seconds
	     sleep 1
	     rcon -s palworld -n shutdown 1 Shutdown_in_1_seconds
	     sleep 10
	    ''}";
    };
    environment = {
      LD_LIBRARY_PATH = "/var/lib/steam-app-${steam-app}/linux64:${pkgs.glibc}/lib";
      SteamAppId = "892970";
    };
  };
}

