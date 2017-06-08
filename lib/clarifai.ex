defmodule Clarifai do
  def predict(urls, models) do
    # TODO
  end

  defdelegate get_tags(image_urls), to: Clarifai.Tag, as: :get
end
