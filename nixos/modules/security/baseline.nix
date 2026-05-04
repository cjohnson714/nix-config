/**
  Opinionated but portable hardening layered on top of other modules.
  Prefer small, well-supported options; use `lib.mkForce` only when you intend to override.
*/
{ lib, ... }:
{
  security.pam.services.su.requireWheel = lib.mkDefault true;

  services.openssh.settings = {
    MaxAuthTries = lib.mkDefault 5;
    LoginGraceTime = lib.mkDefault 30;
    KbdInteractiveAuthentication = lib.mkDefault false;
  };

  boot.kernel.sysctl = {
    "kernel.yama.ptrace_scope" = lib.mkDefault 1;
  };
}
