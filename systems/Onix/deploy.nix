{
  hostname = "192.168.1.65";
  user = "root";
  sshOpts = [ "-o" "StrictHostKeyChecking=no" "-F" "/dev/null" ];
}
