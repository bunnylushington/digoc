defmodule DigOc.Image do

  import DigOc, only: [response: 1]
  import DigOc.Request, only: [putreq: 2, delreq: 1]


  @doc """
  Request that an image be deleted.
  """
  def delete(id), do: delreq("images/#{ id }")

  
  @doc """
  Like `delete/1` but returns the response body only.
  """
  def delete!(id), do: delete(id) |> response


  @doc """
  Request that an image be updated.
  """
  def update(id, new_name), do: putreq("images/#{ id }", %{ name: new_name })

  
  @doc """
  Like `update/2` but returns the response body only.
  """
  def update!(id, new_name), do: update(id, new_name) |> response

end