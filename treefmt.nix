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
  # Spec Kit verifies its installed integration files by checksum. Format only
  # project-owned memory, overrides, extension sources, and feature artifacts.
  settings.formatter.prettier.excludes = [
    ".agents/skills/speckit-*/**"
    ".specify/*.json"
    ".specify/extensions/system-memory/**"
    ".specify/integrations/**"
    ".specify/memory/.constitution-template.json"
    ".specify/templates/*.md"
    ".specify/workflows/speckit/**"
    ".specify/workflows/*.json"
  ];
}
