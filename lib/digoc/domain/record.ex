defmodule DigOc.Domain.Record do

  import DigOc, only: [response: 1]
  import DigOc.Request, only: [postreq: 2]


  @doc """
  Create a new domain record.
  """
  def new(domain, params), do: postreq("domains/#{ domain }/records", params)

  @doc """
  Like `new/2` but return only the response body.
  """
  def new!(domain, params), do: new(domain, params) |> response

end