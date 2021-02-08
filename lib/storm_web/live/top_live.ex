defmodule StormWeb.TopLive do
  use StormWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    <section "section">
      <pre class="is-size-5">
        <%= @top %>
      </pre>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, put_top(socket)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, put_top(socket)}
  end

  defp put_top(socket) do
    {top, 0} = System.cmd("top", ["-n", "1", "-b"])
    assign(socket, top: top)
  end
end
