{ username, ... }:

{
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "23.11";
}
