# Clarifai

[![Hex.pm](https://img.shields.io/hexpm/v/clarifai.svg)](https://hex.pm/packages/clarifai/0.1.1)
[![Travis](https://img.shields.io/travis/ChanChar/clarifai.svg)](https://travis-ci.org/ChanChar/clarifai)
[![license](https://img.shields.io/github/license/chanchar/clarifai.svg)](https://github.com/ChanChar/clarifai/blob/master/LICENSE)

Elixir API for Clarifai.

To use Clarifai's API, you need to sign up and request an API key.
Oauth2 is being deprecated but is still supported by this package. You can still use a client ID and secret.

Visit [Clarifai](https://developer.clarifai.com/) for more information.

After obtaining either an API key or a client ID/secret, update your `config.exs` with the neccesary values.

```elixir
config :clarifai,
  client_id: "your_client_id",
  client_secret: "your_client_secret",
  api_key: "your_api_key",
  version: "v2"
```

## Installation

The package can be installed by adding `clarifai` to your list of dependencies in `mix.exs` and running `mix deps.get`:

```elixir
def deps do
  [{:clarifai, "~> 0.1.1"}]
end
```

## Examples

### Available Models

```elixir
Clarifai.models

=> {
    :ok,
    [
      %Clarifai.Structs.Model{
        app_id: "main",
        created_at: "2017-03-06T22:57:00.707216Z",
        id: "c443119bf2ed4da98487520d01a0b1e3",
        name: "logo",
        output_info: %{
          "message" => "Show output_info with: GET /models/{model_id}/output_info",
          "type" => "concept",
          "type_ext" => "detection"
        },
        version: %{
          "active_concept_count" => 561,
          "created_at" => "2017-03-06T22:57:05.625525Z",
          "id" => "ef1b7237d28b415f910ca343a9145e99",
          "status" => %{
            "code" => 21100, "description" => "Model trained successfully"
          }
        }
      },
      ...
    ]
```

### Available Model Names

```elixir
Clarifai.model_names
=> {
    :ok,
    [
      "logo", "focus", "apparel", "celeb-v1.3", "weddings-v1.0",
      "food-items-v1.0", "nsfw-v1.0", "travel-v1.0", "color", "general-v1.3"
    ]
  }
```

### Tagging images with the given models

```elixir
Clarifai.predict(["https://unsplash.it/5092/3395?image=1062"], ["color", "general-v1.3"])

=> %Clarifai.Structs.Response{
      predictions: [
        %Clarifai.Structs.Prediction{
          image_url: "https://unsplash.it/5092/3395?image=1062",
          status: :ok,
          tags_by_model: [
            %Clarifai.Structs.TagsByModel{
              model: "color",
              tags: [
                %Clarifai.Structs.ColorTag{hex: "#696969", name: "DimGray", value: 0.20425},
                %Clarifai.Structs.ColorTag{hex: "#b0c4de", name: "LightSteelBlue", value: 0.40675},
                %Clarifai.Structs.ColorTag{hex: "#808080", name: "Gray", value: 0.389}
              ]
            },
            %Clarifai.Structs.TagsByModel{
              model: "general-v1.3",
              tags: [
                %Clarifai.Structs.Tag{concept_id: "ai_B2TBwp8F", confidence: 0.9732083, name: "bed"},
                %Clarifai.Structs.Tag{concept_id: "ai_TJ9wFfK5", confidence: 0.96748126, name: "portrait"},
                %Clarifai.Structs.Tag{concept_id: "ai_CnBc0kwc", confidence: 0.94953597, name: "sleep"},
                %Clarifai.Structs.Tag{concept_id: "ai_4CRlSvbV", confidence: 0.9400542, name: "cute"},
                %Clarifai.Structs.Tag{concept_id: "ai_bJt1PfQ5", confidence: 0.91432786, name: "bedroom"},
                %Clarifai.Structs.Tag{concept_id: "ai_j09mzT6j", confidence: 0.9100505, name: "family"},
                %Clarifai.Structs.Tag{concept_id: "ai_8S2Vq3cR", confidence: 0.89849144, name: "dog"},
                ...,
                %Clarifai.Structs.Tag{concept_id: "ai_SzsXMB1w", confidence: 0.7452092, name: "animal"}
              ]
            }
          ]
        }
      ]
    }
```
