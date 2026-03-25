{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    ruby.devEnv
    gem
    jekyll
    bundler
    go-task
    curl
    git
    gum
    python3
    ripgrep
  ];
  shellHook = ''
    echo "Legacy nix-shell loaded. Canonical local environment is devenv via direnv."
  '';
}
