defmodule DigOc do

  import DigOc.Request, only: [req: 1,    
                               postreq: 2,
                               putreq: 2, 
                               delreq: 1 ]

  @endpoint "https://api.digitalocean.com/v2/"
  @token_varible "DIGOC_API2_TOKEN"
  @per_page 25
  @wait_time_ms 5000


  @doc """
  Return the endpoint URL as a string.
  """
  def endpoint, do: @endpoint

  @doc """
  Return the D.O. API token as a string.  The token should be the value of 
  the environment variable DIGOC_API2_TOKEN.
  """
  def api_token, do: System.get_env(@token_varible)

  defp response({_, body, _}), do: body

  # ------------------------- ACCOUNT.
  def account, do: req("account")
  def account!, do: account |> response


  # ------------------------- ACTIONS.
  def actions(per_page \\ @per_page), do: req("actions?per_page=#{ per_page }")
  def actions!(per_page \\ @per_page), do: actions(per_page) |> response

  def action(id), do: req("actions/#{ id }")
  def action!(id), do: action(id) |> response

  # ------------------------- DROPLETS.
  def droplets, do: req("droplets")
  def droplets!, do: droplets |> response

  def droplet(id), do: req("droplets/#{ id }")
  def droplet!(id), do: droplet(id) |> response

  def droplet(:kernels, id), do: req("droplets/#{ id }/kernels")
  def droplet(:snapshots, id), do: req("droplets/#{ id }/snapshots")
  def droplet(:backups, id), do: req("droplets/#{ id }/backups")
  def droplet(:actions, id), do: req("droplets/#{ id }/actions")
  def droplet(:new, props), do: postreq("droplets", props)
  def droplet(:delete, id), do: delreq("droplets/#{ id }")

  def droplet!(:kernels, id), do: droplet(:kernels, id) |> response
  def droplet!(:snapshots, id), do: droplet(:snapshots, id) |> response
  def droplet!(:backups, id), do: droplet(:backups, id) |> response
  def droplet!(:actions, id), do: droplet(:actions, id) |> response
  def droplet!(:new, props), do: droplet(:new, props) |> response
  def droplet!(:delete, id), do: droplet(:delete, id) |> response

  def upgrades, do: req("droplet_upgrades")
  def upgrades!, do: upgrades |> response

  def wait_for_status(droplet_id, desired_status) do
    if droplet!(droplet_id).droplet.status == to_string(desired_status) do
      :ok
    else
      IO.puts :stderr, 
         "Waiting for droplet #{ droplet_id } to become #{ desired_status }."
      :timer.sleep(@wait_time_ms)
      wait_for_status(droplet_id, desired_status)
    end
  end

  def pretty_print(droplet_list) do
    DigOc.Pretty.droplets(droplet_list)
  end

  # ------------------------- IMAGES.
  def images(type \\ nil) do
    query = if type, do: "?type=#{ type }", else: ""
    req("images#{ query }")
  end
  def images!(type \\ nil), do: images(type) |> response

  def image(id), do: req("images/#{ id }")
  def image!(id), do: image(id) |> response

  def image(:delete, id), do: :not_implemented
  def image(:update, id, name), do: :not_implemented

  def image!(:delete, id), do: image(:delete, id) |> response
  def image!(:update, id, name), do: image(:update, id, name) |> response

  # ------------------------- SSH KEYS.
  def keys, do: req("account/keys")
  def keys!, do: keys |> response

  def key(id), do: req("account/keys/#{ id }")
  def key!(id), do: key(id) |> response

  def key(:new, name, public_key) do
    postreq("account/keys", %{ name: name, public_key: public_key})
  end

  def key(:update, id, new_name) do
    putreq("account/keys/#{ id }", %{ name: new_name })
  end
  def key!(:update, id, new_name), do: key(:update, id, new_name) |> response

  def key!(:new, name, public_key), do: key(:new, name, public_key) |> response

  def key(:destroy, id), do: delreq("account/keys/#{ id }")
  def key!(:destroy, id), do: key(:destroy, id) |> response


  # ------------------------- REGIONS.
  def regions, do: req("regions")
  def regions!, do: regions |> response

  # ------------------------- SIZES.
  def sizes, do: req("sizes")
  def sizes!, do: sizes |> response

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
  defp get_page!(data, page), do: get_page(data, page) |> response

  defp _get_page(data, page, req_macro) do
    if has_page?(data, page) do
      req_macro.(Dict.get(data.links.pages, page))
    else
      raise("No bookmark for #{ page } page.")
    end
  end    
    

end
