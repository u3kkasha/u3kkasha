_: {
  # Used to find the project root
  projectRootFile = "LICENSE";

  # Nix
  # Format Nix files
  programs.nixfmt.enable = true;
  # Lint Nix files
  programs.statix.enable = true;
  # Remove unused Nix code
  programs.deadnix.enable = true;

  # Markdown
  # Format Markdown files
  programs.prettier.enable = true;
}
