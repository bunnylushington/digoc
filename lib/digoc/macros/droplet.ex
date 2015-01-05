defmodule DigOc.Macros.Droplet do

  defmacro make_action(action) do
    bang_name = String.to_atom(to_string(action) <> "!")
    quote do

      @doc """
      Take the action __#{ unquote(action) }__ on the droplet.

      An action object will be returned.  When that object no longer
      has a status of "in-progress" an event will be posted to the
      event manager.
      """
      def unquote(action)(id), do: task(id, unquote(action))

      @doc """
      Like `#{ unquote(action) }` but returns the response body only.
      """
      def unquote(bang_name)(id), do: unquote(action)(id) |> response
    end
  end

  defmacro make_action(action, key) do
    bang_name = String.to_atom(to_string(action) <> "!")
    quote do

      @doc """
      Take the action __#{ unquote(action) }__ on the droplet.  

      Both the droplet id and the #{ unquote(key) } must be provided.
                                  
      An action object will be returned.  When that object no longer
      has a status of "in-progress" an event will be posted to the
      event manager.
      """
      def unquote(action)(id, value) do
        task(id, unquote(action), %{ unquote(key) => value })
      end


      @doc """
      Like `#{ unquote(action) }/2` but returns the response body only.
      """
      def unquote(bang_name)(id, value) do
        unquote(action)(id, value) |> response
      end
    end
  end

end