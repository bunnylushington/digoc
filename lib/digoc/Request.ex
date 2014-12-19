defmodule DigOc.Request do
  use HTTPoison.Base

  def process_url(url) do
    if String.starts_with?(url, DigOc.endpoint) do 
      url
    else 
      DigOc.endpoint <> url
    end
  end
  
  def process_request_headers(_headers) do
    [{ "Authorization", "Bearer #{ DigOc.api_token }"}]
  end

end