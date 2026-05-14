{ ... }:

{
  # This module manages the gemini-cli configuration.
  # You can add more settings here as you discover them.
  
  home.file.".config/gemini-cli/config.yaml" = {
    text = ''
      # Gemini CLI Configuration
      # Automatically managed by Home Manager
      
      # Example structure (adjust based on your actual config needs):
      # model: gemini-1.5-pro-latest
      # temperature: 0.7
    '';
    # set force = true if you want to overwrite manual changes every time you rebuild
    force = false; 
  };

  # MCP Servers Configuration
  # This is usually a JSON file where you define your servers.
  # Note: You'll need to update the paths to point to where your MCP server binaries are.
  home.file.".config/gemini-cli/mcp_servers.json" = {
    text = ''
      {
        "mcpServers": {
          "example-server": {
            "command": "node",
            "args": ["/path/to/server/index.js"]
          }
        }
      }
    '';
    force = false;
  };
}
