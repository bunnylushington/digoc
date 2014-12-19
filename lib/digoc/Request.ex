defmodule DigOc.Request do
  use HTTPoison.Base

  def process_url(url) do
    DigOc.endpoint <> url
  end
  
  def process_request_headers(_headers) do
    [{ "Authorization", "Bearer #{ DigOc.api_token }"}]
  end

end