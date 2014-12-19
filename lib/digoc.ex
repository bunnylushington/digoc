defmodule DigOc do

  @endpoint "https://api.digitalocean.com/v2/"
  @token_varible "DIGOC_API2_TOKEN"
  @per_page 25

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
  

  # ------------------------- ACTIONS.
  def actions(per_page \\ @per_page) do
    {:ok, response} = DigOc.Request.get("actions?per_page=#{ per_page }")
    {:ok, Poison.decode!(response.body, keys: :atoms), response.headers}
  end

  def actions!(per_page \\ @per_page) do
    {_, res, _} = actions(per_page)
    res
  end

  def action(id) do
    {:ok, response} = DigOc.Request.get("actions/#{ id }")
    {:ok, Poison.decode!(response.body, keys: :atoms), response.headers}
  end

  def action!(id) do
    {_, res, _} = action(id)
    res
  end


  # ------------------------- PAGINATION.
  def has_next?(data),  do: has_page?(data, :next)
  def has_prev?(data),  do: has_page?(data, :prev)
  def has_first?(data), do: has_page?(data, :first)
  def has_last?(data),  do: has_page?(data, :last)
  
  def next_page(data),     do: get_page(data, :next)
  def prev_page(data),     do: get_page(data, :prev)
  def previous_page(data), do: get_page(data, :prev)
  def last_page(data),     do: get_page(data, :last)
  def first_page(data),    do: get_page(data, :first)

  def next_page!(data),     do: get_page!(data, :next)
  def prev_page!(data),     do: get_page!(data, :prev)
  def previous_page!(data), do: get_page!(data, :prev)
  def last_page!(data),     do: get_page!(data, :last)
  def first_page!(data),    do: get_page!(data, :first)

  defp has_page?(data, page), do: Dict.has_key?(data.links.pages, page)

  defp get_page(data, page) do
    if has_page?(data, page) do
      Dict.get(data.links.pages, page) |> get_link
    else
      raise("No bookmark for #{ page } page.")
    end
  end

  defp get_page!(data, page) do
    if has_page?(data, page) do
      Dict.get(data.links.pages, page) |> get_link!
    else
      raise("No bookmark for #{ page } page.")
    end
  end

  defp get_link(url) do
    {:ok, response} = DigOc.Request.get(url)
    {:ok, Poison.decode!(response.body, keys: :atoms), response.headers}
  end

  defp get_link!(url) do
    {_, res, _} = get_link(url)
    res
  end

end
