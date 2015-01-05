defmodule DigOc do

  import DigOc.Request, only: [req: 1, postreq: 2, putreq: 2, delreq: 1 ]

  @endpoint "https://api.digitalocean.com/v2/"
  @token_varible "DIGOC_API2_TOKEN"
  @per_page 25
  @wait_time_ms 5000
  @event_manager DigOc.EM

  @doc """
  Return the endpoint URL as a string.

  Example:
    iex> DigOc.endpoint
    "https://api.digitalocean.com/v2/"

  """
  def endpoint, do: @endpoint


  @doc """
  Return the API token as a string.  The token should be the value of 
  the environment variable DIGOC_API2_TOKEN.
  """
  def api_token, do: System.get_env(@token_varible)


  @doc """
  Return the name of the event manager.

  Example:
    iex> DigOc.event_manager
    DigOc.EM

  """
  def event_manager, do: @event_manager


  @doc """
  Return the time (in ms) to wait when polling for actions to complete.
  
  Example: 
    iex> DigOc.wait_time
    5000
  """
  def wait_time, do: @wait_time_ms


  @doc """
  Parse the result body out of an HTTPoison response tuple.

  Example:
    iex> res = {:ok, %{ body: "contents" }, %{ result: 200 } }
    iex> DigOc.response(res)
    %{ body: "contents" }
  """
  def response({_, body, _}), do: body
  

  @doc """
  Given a result or a result body, return the droplet ID.

  Example: 
    iex> res = {:ok, %{ droplet: %{ id: 123, name: "example" } }, %{}}
    iex> DigOc.id_from_result(res)
    123
  """
  def id_from_result(res), do: feature_from_result(res, :id)


  @doc """
  Given a result or result body and a droplet map key, return 
  the value associated with that key.

  Example:
    iex> res = {:ok, %{ droplet: %{ id: 123, name: "example" } }, %{}}
    iex> DigOc.feature_from_result(res, :id)
    123
    iex> DigOc.feature_from_result(DigOc.response(res), :name)
    "example"
  """
  def feature_from_result(res, f) when is_map(res), do: res.droplet[f]
  def feature_from_result({_, body, _}, f), do: body.droplet[f]


  @doc """
  Make a predicate name from the supplied atom.  

  Example:
    iex> DigOc.predicate(:next)
    :next?
  """
  # We use the codepoint for ? here because emacs's elixir mode gets a
  # little confused with the simple question mark.
  def predicate(atom), do: String.to_atom(to_string(atom) <> "\x{3F}")


  @doc """
  Make a bang-name from the supplied atom.  

  Example:
    iex> DigOc.bang(:next)
    :next!
  """
  def bang(atom), do: String.to_atom(to_string(atom) <> "!")
  

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
  def droplet(:new, props) do
    res = postreq("droplets", props)
    droplet_id = id_from_result(res)
    spawn(DigOc, :wait_for_status, [droplet_id, :active])
    res
  end
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
      GenEvent.sync_notify(event_manager, 
                           {:achieved_status, droplet_id, desired_status})
    else
      :timer.sleep(wait_time)
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

end
