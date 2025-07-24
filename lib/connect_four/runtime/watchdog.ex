defmodule ConnectFour.Runtime.Watchdog do

  def start(expiry_time, notify_pid \\ self()) do
    spawn_link(fn -> watcher(expiry_time, notify_pid) end)
  end

  def im_alive(watcher) do
    send(watcher, :im_alive)
  end

  defp watcher(expiry_time, notify_pid) do
    receive do
      :im_alive ->
        watcher(expiry_time, notify_pid)

    after expiry_time ->
      send(notify_pid, {:watchdog_expired, self()})
      Process.exit(self(), { :shutdown, :watchdog_triggered })
    end
  end
end
