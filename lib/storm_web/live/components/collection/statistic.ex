defmodule StormWeb.Live.Components.Collection.Statistic do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <nav class="level">
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">ideas</p>
          <p class="title"><%= @ideas %></p>
        </div>
      </div>
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">pros</p>
          <p class="title"><%= @pros %></p>
        </div>
      </div>
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">cons</p>
          <p class="title"><%= @cons %></p>
        </div>
      </div>
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">comments</p>
          <p class="title"><%= @comments %></p>
        </div>
      </div>
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">likes</p>
          <p class="title"><%= @likes %></p>
        </div>
      </div>
    </nav>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def update(
        %{
          pros: pros,
          cons: cons,
          comments: comments,
          ideas: ideas,
          likes: likes
        } = _assigns,
        socket
      ) do
    {:ok, assign(socket, pros: pros, cons: cons, comments: comments, ideas: ideas, likes: likes)}
  end
end
