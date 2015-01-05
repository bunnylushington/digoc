defmodule DigOc do

  import DigOc.Request, only: [req: 1, postreq: 2, putreq: 2, delreq: 1 ]

  @endpoint "https://api.digitalocean.com/v2/"
  @token_varible "DIGOC_API2_TOKEN"
  @per_page 25
  @wait_time_ms 5000
  @event_manager DigOc.EM

  @moduledoc """ 

  This is an Elixir client for the Digital Ocean API, verion 2.
  Details about the API can be found on [Digital Ocean's documentation
  site.](https://developers.digitalocean.com/)

  """

  @doc """
  The endpoint URL as a string.

  ## Examples

      iex> DigOc.endpoint
      "https://api.digitalocean.com/v2/"

  """
  def endpoint, do: @endpoint


  @doc """
  The API token as a string.  

  The token is the value associated with the environment variable
  `DIGOC_API2_TOKEN`.

  """
  def api_token, do: System.get_env(@token_varible)


  @doc """
  The name of the event manager.

  ## Examples

      iex> DigOc.event_manager
      DigOc.EM

  """
  def event_manager, do: @event_manager


  @doc """
  The time (in ms) to wait when polling for actions to complete.
  
  ## Examples

      iex> DigOc.wait_time
      5000

  """
  def wait_time, do: @wait_time_ms


  @doc """
  Parse the result body out of an HTTPoison response tuple.

  ## Examples

      iex> res = {:ok, %{ body: "contents" }, %{ result: 200 } }
      iex> DigOc.response(res)
      %{ body: "contents" }

  """
  def response({_, body, _}), do: body
  

  @doc """
  Given a result or a result body, return the droplet ID.

  ## Examples

      iex> res = {:ok, %{ droplet: %{ id: 123, name: "example" } }, %{}}
      iex> DigOc.id_from_result(res)
      123

  """
  def id_from_result(res), do: feature_from_result(res, :id)


  @doc """
  Given a result or result body and a droplet map key, return 
  the value associated with that key.

  ## Examples

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

  ## Examples

      iex> DigOc.predicate(:next)
      :next?

  """
  # We use the codepoint for ? here because emacs's elixir mode gets a
  # little confused with the simple question mark.
  def predicate(atom), do: String.to_atom(to_string(atom) <> "\x{3F}")


  @doc """
  Make a bang-name from the supplied atom.  

  ## Examples
      iex> DigOc.bang(:next)
      :next!

  """
  def bang(atom), do: String.to_atom(to_string(atom) <> "!")
  

  # ------------------------- ACCOUNT.
  @doc """
  Requests information about the registered account.
  """
  def account, do: req("account")

  @doc """ 
  Like `account/0` but returns response body only.
  """
  def account!, do: account |> response


  # ------------------------- ACTIONS.
  @doc """
  Requests a list of actions, i.e., records of events.

  [Documentation.](https://developers.digitalocean.com/#list-all-actions)
  """
  def actions(per_page \\ @per_page), do: req("actions?per_page=#{ per_page }")


  @doc """
  Like `actions/1` but returns response body only.
  """
  def actions!(per_page \\ @per_page), do: actions(per_page) |> response


  @doc """
  Requests a particular action record by id.  
  """
  def action(id), do: req("actions/#{ id }")


  @doc """
  Like `action/1` but returns response body only.
  """
  def action!(id), do: action(id) |> response

  # ------------------------- DROPLETS.
  @doc """
  Requests a list of all droplets.
  """
  def droplets, do: req("droplets")


  @doc """
  Like `droplets/0` but returns response body only.
  """
  def droplets!, do: droplets |> response


  @doc """
  Requests a particular droplet object by id.
  """
  def droplet(id), do: req("droplets/#{ id }")


  @doc """
  Like `droplet/1` but returns response body only.
  """
  def droplet!(id), do: droplet(id) |> response


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
