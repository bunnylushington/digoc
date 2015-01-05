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
    [{ "Authorization", "Bearer #{ DigOc.api_token }" }] ++ headers
  end

  def process_response_body(""), do: ""
  def process_response_body(body) do
    Poison.decode!(body, keys: :atoms)
  end

  def postreq(path, body) do
    encoded = Poison.Encoder.encode(body, [])
    {:ok, response} = 
      DigOc.Request.post(path, encoded, 
                         [{ "Content-type", "application/json"} ])
    {:ok, response.body, response.headers}
  end

  def putreq(path, body) do
    encoded = Poison.Encoder.encode(body, [])
    {:ok, response} = 
      DigOc.Request.put(path, encoded, [{ "Content-type", "application/json"} ])
    {:ok, response.body, response.headers}
  end

  def delreq(path) do
    {:ok, response} = DigOc.Request.delete(path)
    {:ok, response.body, response.headers}
  end

  def req(path) do
    {:ok, response} = DigOc.Request.get(path)
    {:ok, response.body, response.headers}
  end

end