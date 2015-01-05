defmodule DigOc.Key do

  import DigOc, only: [response: 1]
  import DigOc.Request, only: [postreq: 2, putreq: 2, delreq: 1]


  @doc """
  Register a new key.
  """
  def new(name, public_key) do
    postreq("account/keys", %{ name: name, public_key: public_key })
  end

  
  @doc """
  Like `new/2` but only returns response body.
  """
  def new!(name, public_key), do: new(name, public_key) |> response


  @doc """
  Rename a key.  The id parameter may be the id or fingerprint.
  """
  def update(id, new_name) do
    putreq("account/keys/#{ id }", %{ name: new_name })
  end


  @doc """
  Like `update/2` but only returns the response body.
  """
  def update!(id, new_name), do: update(id, new_name) |> response


  @doc """
  Destroys a key.  The id parameter may be the id or fingerprint.
  """
  def destroy(id), do: delreq("account/keys/#{ id }")
  
  
  @doc """
  Like `destroy/1` but only returns the response body.
  """
  def destroy!(id), do: destroy(id) |> response


end