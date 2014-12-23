defmodule DigOc do

  import DigOc.Request, only: [req: 1,     req!: 1, 
                               postreq: 2, postreq!: 2,
                               putreq: 2,  putreq!: 2,
                               delreq: 1,  delreq!: 1 ]

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
  def account, do: req("account")
  def account!, do: req!("account")


  # ------------------------- ACTIONS.
  def actions(per_page \\ @per_page), do: req("actions?per_page=#{ per_page }")
  def actions!(per_page \\ @per_page), do: req!("actions?per_page=#{per_page}")

  def action(id), do: req("actions/#{ id }")
  def action!(id), do: req!("actions/#{ id }")


  # ------------------------- SSH KEYS.
  def keys, do: req("account/keys")
  def keys!, do: req!("account/keys")

  def key(id), do: req("account/keys/#{ id }")
  def key!(id), do: req!("account/keys/#{ id }")

  def key(:new, name, public_key) do
    postreq("account/keys", %{ name: name, public_key: public_key})
  end

  def key(:update, id, new_name) do
    putreq("account/keys/#{ id }", %{ name: new_name })
  end

  def key!(:new, name, public_key) do
    postreq!("account/keys", %{ name: name, public_key: public_key})
  end

  def key!(:update, id, new_name) do
    putreq!("account/keys/#{ id }", %{ name: new_name })
  end


  def key(:destroy, id), do: delreq("account/keys/#{ id }")
  def key!(:destroy, id), do: delreq("account/keys/#{ id }")


  # ------------------------- REGIONS.
  def regions, do: req("regions")
  def regions!, do: req!("regions")

  # ------------------------- SIZES.
  def sizes, do: req("sizes")
  def sizes!, do: req!("sizes")

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

  defp get_page(data, page), do: _get_page(data, page, &req/1)
  defp get_page!(data, page), do: _get_page(data, page, &req!/1)

  defp _get_page(data, page, req_macro) do
    if has_page?(data, page) do
      req_macro.(Dict.get(data.links.pages, page))
    else
      raise("No bookmark for #{ page } page.")
    end
  end    
    

end
