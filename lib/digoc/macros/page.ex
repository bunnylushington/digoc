defmodule DigOc.Macros.Page do

  defmacro navigate(direction) do
    predicate = DigOc.predicate(direction)
    bang_name = DigOc.bang(direction)
    quote do
      @doc """
      Test if #{ unquote(direction) } page is defined.
      """
      def unquote(predicate)(data), do: has_page?(data, unquote(direction))
      
      @doc """
      Request #{ unquote(direction) } page.  Returns HTTPoison 3-tuple.
      """
      def unquote(direction)(data), do: get_page(data, unquote(direction))

      @doc """
      Request #{ unquote(direction) } page.  Returns only the response body.
      """
      def unquote(bang_name)(data), do: unquote(direction)(data) |> response
    end
  end

end

