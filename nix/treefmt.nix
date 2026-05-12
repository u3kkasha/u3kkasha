_: {
  # Used to find the project root
  projectRootFile = "flake.nix";

  # Nix
  # Format Nix files
  programs.nixfmt.enable = true;
  # Lint Nix files
  programs.statix.enable = true;
  # Remove unused Nix code
  programs.deadnix.enable = true;

  # Markdown, YAML, and JSON
  # Format documentation and config files
  programs.prettier.enable = true;
  programs.prettier.includes = [
    "*.md"
    "*.yaml"
    "*.yml"
    "*.json"
  ];
}
