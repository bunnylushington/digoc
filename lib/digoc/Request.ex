defmodule DigOc.Request do
  use HTTPoison.Base

  def process_url(url) do
    if String.starts_with?(url, DigOc.endpoint) do 
      url
    else 
      DigOc.endpoint <> url
    end
  end
  
  def process_request_headers(headers) do
    headers |> Keyword.merge [{ "Authorization", "Bearer #{ DigOc.api_token }"}]
  end

  def process_response_body(body) do
    Poison.decode!(body, keys: :atoms)
  end


  defmacro req(path) do
    quote do
      {:ok, response} = DigOc.Request.get(unquote(path))
      {:ok, response.body, response.headers}
    end
  end

  defmacro req!(path) do
    quote do
      {_, body, _} = req(unquote(path))
      body
    end
  end


end