defmodule DigOc do

  @endpoint "https://api.digitalocean.com/v2/"
  @token_varible "DIGOC_API2_TOKEN"

  @doc """
  Return the endpoint URL as a string.
  """
  def endpoint, do: @endpoint

  @doc """
  Return the D.O. API token as a string.  The token should be the value of 
  the environment variable DIGOC_API2_TOKEN.
  """
  def api_token, do: System.get_env(@token_varible)


  # ------------------------- ACCOUNT.
  @doc """
  Get the account information.  Returns a 3-tuple {:ok, %data, %headers}.
  """
  def account do
    {:ok, response} = DigOc.Request.get("account")
    {:ok, Poison.decode!(response.body, keys: :atoms), response.headers}
  end

  @doc """
  Like account but only returns the account data as a dictionary.
  """
  def account! do
    {_, res, _} = account
    res
  end
  

end
