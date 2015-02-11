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
  

  @doc """
  Request a page from Digital Ocean.  Most likely used to retrieve pages
  that are specified somewhere in the :links key (like the next or previous 
  page of results.
  """
  def page(url), do: req(url)

  @doc """
  Like `page/1` but only return the response body.
  """
  def page!(url), do: req(url) |> response
    
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

  
  # ------------------------- DOMAINS.
  @doc """
  Request a list of domains.
  """
  def domains, do: req("domains")
  
  
  @doc """
  Like `domains/0` but returns the response body only.
  """
  def domains!, do: domains |> response
  

  @doc """
  Request a domain by name.
  """
  def domain(name), do: req("domains/#{ name }")

  
  @doc """
  Like `domain/1` but returns the response body only.
  """
  def domain!(name), do: domain(name) |> response

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


  @doc """
  Requests all droplet neighbors.
  """
  def droplet_neighbors, do: req("reports/droplet_neighbors")

  @doc """
  Like `droplet_neighbors/0` but returns response body only.
  """
  def droplet_neighbors!, do: droplet_neighbors |> response

  @doc """
  Requests neighbors for the supplied droplet ID.
  """
  def droplet_neighbors(id), do: req("droplets/#{ id }/neighbors")

  @doc """
  Like `droplet_neighbors/1` but returns response body only.
  """
  def droplet_neighbors!(id), do: droplet_neighbors(id) |> response
    

  # ------------------------- IMAGES.
  @doc """
  Lists available images.  

  Type may be :application, :distribution, or :private.
  """
  def images(type \\ nil) do
    query = case type do
              nil -> ""
              :private -> "?private=true"
              other -> "?type=#{ other }"
            end
    req("images#{ query }")
  end

  
  @doc """
  Like `images/1` but returns response body only.
  """
  def images!(type \\ nil), do: images(type) |> response

  
  @doc """
  Return an image by id.
  """
  def image(id), do: req("images/#{ id }")


  @doc """
  Like `image/1` but returns response body only.
  """
  def image!(id), do: image(id) |> response


  # ------------------------- SSH KEYS.
  @doc """
  Requests a list of keys associated with the account.
  """
  def keys, do: req("account/keys")


  @doc """
  Like `keys/0` but returns only the response body.
  """
  def keys!, do: keys |> response


  @doc """
  Requests a specific key (by id or fingerprint).
  """
  def key(id), do: req("account/keys/#{ id }")


  @doc """
  Like `key/1` but returns only the response body.
  """
  def key!(id), do: key(id) |> response


  # ------------------------- REGIONS.
  @doc """
  Requests a list of regions.
  """
  def regions, do: req("regions")


  @doc """
  Like `regions/0` but only returns the response body.
  """
  def regions!, do: regions |> response

  # ------------------------- SIZES.
  @doc """
  Requests a list of droplet sizes.
  """
  def sizes, do: req("sizes")

  @doc """
  Like `sizes/0` but only returns the response body.
  """
  def sizes!, do: sizes |> response

end
