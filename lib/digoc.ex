defmodule DigOc do

  @endpoint "https://api.digitalocean.com/v2/"
  @token_varible "DIGOC_API2_TOKEN"

  @doc """
  Return the endpoint URL as a string.
  """
  def endpoint, do: @endpoint

  @doc """
  Return the D.O. API token as a string.
  """
  def api_token, do: System.get_env(@token_varible)
  

end
