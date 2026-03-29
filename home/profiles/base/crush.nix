{ pkgs, ... }:
{
  home.packages = with pkgs; [
    crush
  ];

  xdg.dataFile."crush/crush.json".text = builtins.toJSON {
    providers = {
      ollama = {
        type = "openai";
        api_endpoint = "http://ai.sapphire.home:11434/v1";
        api_key = "ollama";
        default_large_model_id = "qwen3:latest";
        default_small_model_id = "qwen3:latest";
        models = [
          {
            id = "qwen3:latest";
            name = "Qwen 3 Latest";
          }
        ];
      };
    };
    models = {
      large = {
        model = "qwen3:latest";
        provider = "ollama";
        max_tokens = 8192;
      };
      small = {
        model = "qwen3:latest";
        provider = "ollama";
        max_tokens = 8192;
      };
    };
  };
}
