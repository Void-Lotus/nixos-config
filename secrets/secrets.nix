# secrets.nix defines keys for decrypting age secrets.
# You can encrypt a secret using: agenix -e secret1.age
let
  # The user's public SSH key (from ~/.ssh/id_ed25519.pub)
  userKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAyi2+YzKUHVPcxSVlfaYeUh9Lkjt4f+QsyL+Czf8tG Void-Lotus@github";

  # The host's public SSH key (typically from /etc/ssh/ssh_host_ed25519_key.pub)
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG//+tVrMG5THisCoP9yn+E8SrsfL0zedaSKRyJzAW57 root@nixlotus";

  # All keys that should be able to decrypt secrets
  allKeys = [ userKey ] ++ (if hostKey != "" then [ hostKey ] else []);
in
{
  # Example secret mapping
  # "secret1.age".publicKeys = allKeys;
}
