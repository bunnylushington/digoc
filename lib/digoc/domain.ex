defmodule DigOc.Domain do
  
  import DigOc.Request, only: [req: 1, postreq: 2, putreq: 2, delreq: 1 ]
  import DigOc, only: [response: 1]


  @doc """
  Request that a new domain be created.
  """
  def new(name, ip), do: postreq("domains", %{ name: name, ip_address: ip })


  @doc """
  Like `new/2` but returns only the response body.
  """
  def new!(name, id), do: new(name, id) |> response


  @doc """
  Request that a domain be deleted.
  """
  def delete(name), do: delreq("domains/#{ name }")


  @doc """
  Like `delete/1` but returns only the response body.
  """
  def delete!(name), do: delete(name) |> response

end