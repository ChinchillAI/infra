{ modulesPath, inputs, pkgs, configRevision, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/palworld.nix
  ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    loader.grub = {
      zfsSupport = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    kernelParams = [ "net.ifnames=0" ];
    zfs.devNodes = "/dev";
  };

  services.openssh.enable = true;

  networking = {
    hostName = "uppie";
    defaultGateway = "45.8.22.1";
    nameservers = [ "9.9.9.9" ];
    interfaces.eth0 = {
      ipAddress = "45.8.22.94";
      prefixLength = 24;
    };
    hostId = "36449921";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhzSb0t3XxmRznThUb7EOW51yFQULht02frD+7/lQDeouqjxxpiPhVCH0bEQdtX2lcUyEnK52RusAoXBYnTvjcgaLc9kypDY82UMndrqAFPk434y3SslEbJCubU/iOJ+z9g3mOJH8v02mXOIINhuvkzQyaekkZ3xR7m/yemPfwfx99TqnYUD/yuIrIn3gQcsHAdWtgk+vTrH2q8uGkcZyENaRkM9uS2OEr688KBUA+QnpT/9GGdR0y+saqMFryqFL0TE7Lemesoir+1cV0ibBb5gGCQr2ZppmDJ6f2CB2AHcd/9XXIy5n98zFdSUUr/kl02L62lQt5zzm+8Z7iEE7+82ea+RgBQy+QuTSFmjD+MhI6Y+zP+MiQmugUkGfCfyosD5PZgqlxuWCPKT7sNFjS8TK8lYbwc8kvqoTe+Ve10GT6Hq3My6eoMiJi4996ZjboyAZ064xXhIzan97viY+KYEZqrJOnfU98aTfmhbc0l2HbYp3decZsbAOwFb85ZKdDNagheIDeCtjHr9L8sG0FFhO6JdeUuUm17w9AVtBgJ0X83PLxmrx+Y+WdMx646/PYs6340/cQkXCy45iORPicWD5pqCciHYDzukYeZ+PbrIHoiTWYYIfnsXM3piE8c4tkhvfsbxJpdo9YTq/hXNbQCvvjqyoNOEMuxMbWJhBNZQ== chinchillAI"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEz5kBF9xzg6fej1zjgk29c+oRcl4Lv8GSnV8Bt5cAyF Firworks"
  ];

  system = {
    stateVersion = "23.11";
    configurationRevision = configRevision.full;
  };
}
