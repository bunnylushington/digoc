defmodule DigOc.Droplet do

  import DigOc, only: [response: 1, event_manager: 0, wait_time: 0]
  import DigOc.Request, only: [req: 1, postreq: 2]
  require DigOc.Macros.Droplet, as: M

  @moduledoc """ 

  For each of the actions (power_cycle, reboot, &c.) an action record
  is returned.  When that happens, an async polling loop is created
  that monitors that record for the status to change from
  "in-progress."  When it does, a message is posted to the event
  manager.  That message has the payload:

      { :action_finished, droplet_id, action_id, action_record }

  Handlers may be attached to the event manager to take appropriate
  actions upon completion.  Note that the EM's name can be disovered
  with `DigOc.event_manager/0`.

  """

  M.make_action(:power_cycle)
  M.make_action(:reboot)
  M.make_action(:shutdown)
  M.make_action(:power_off) 
  M.make_action(:power_on) 
  M.make_action(:password_reset) 
  M.make_action(:enable_ipv6) 
  M.make_action(:enable_private_networking) 
  M.make_action(:migrate_droplet) 
  M.make_action(:disable_backups) 
  M.make_action(:restore, :image) 
  M.make_action(:resize, :size) 
  M.make_action(:rebuild, :image) 
  M.make_action(:rename, :name) 
  M.make_action(:change_kernel, :kernel) 
  M.make_action(:snapshot, :name) 

  defp task(id, action, extra \\ %{}) do
    map = Map.merge( %{ type: action }, extra )
    res = postreq("droplets/#{ id }/actions", map) 
    action_id = feature_from_action(res, :id)
    spawn(__MODULE__, :wait_for_action, [id, action_id])
    res
  end    

  defp action(droplet_id, action_id) do
    req("droplets/#{ droplet_id }/actions/#{ action_id }")
  end

  defp action!(droplet_id, action_id) do
    action(droplet_id, action_id) |> response
  end


  @doc """
  Occasionally polls until an action object has a status of something
  other than "in-progress".  The poll interval is determined by the
  value returned by `DigOc.wait_time/0`.  When the status changes a
  notification, described above, is posted to the event manager.
  """
  def wait_for_action(droplet_id, action_id) do
    action = action!(droplet_id, action_id)
    if action.action.status !== "in-progress" do
      payload = {:action_finished, droplet_id, action_id, action.action}
      GenEvent.sync_notify(event_manager, payload)
    else
      :timer.sleep(wait_time)
      wait_for_action(droplet_id, action_id)
    end
  end

  
  def feature_from_action(res, f) when is_map(res), do: res.action[f]
  def feature_from_action({_, body, _}, f), do: body.action[f]

end
