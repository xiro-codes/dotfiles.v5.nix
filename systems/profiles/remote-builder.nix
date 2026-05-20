{ ... }:
{
  users.users.build = {
    isNormalUser = true;
    description = "Nix remote build user";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7231Oawo+cIcWU22G0qfWh5N77r0neXl0ZSTWLQz+f build@installer-iso"
    ];
  };

  nix.settings.trusted-users = [ "build" ];
}
