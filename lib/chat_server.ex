defmodule ChatServer do
  use GenServer

  alias ChatServer.Messages

  def start_link(_) do
    GenServer.start_link(__MODULE__, initial_state(), name: __MODULE__)
  end

  defp initial_state() do
    %{
      users: %{},
      messages: []
    }
  end

  def init(init_arg), do: {:ok, init_arg}

  def get_all_users() do
    GenServer.call(__MODULE__, :get_all_users)
  end
  def get_all_messages() do
    GenServer.call(__MODULE__, :get_all_messages)
  end

  def add_user(user_id, username) do
    GenServer.cast(__MODULE__, {:add_user, user_id, username})
  end

  def remove_user(user_id) do
    GenServer.cast(__MODULE__, {:remove_user, user_id})
  end

  def send_message(%{user_id_from: user_id_from, user_id_to: user_id_to, content: content}) do
    GenServer.cast(__MODULE__, {:send_message, user_id_from, user_id_to, content})
  end

  def receive_messages(user_id_to) do
    GenServer.cast(__MODULE__, {:receive_messages, user_id_to})
  end

  defp user_exists(user_id_from, user_id_to, state) do
    case {Map.get(state.users, user_id_from), Map.get(state.users, user_id_to)} do
      {nil, _} ->  {:error, "User with id #{user_id_from} not found"}
      {_, nil} ->  {:error, "User with id #{user_id_to} not found"}
      {_, _} -> {:ok}
    end
  end

  def handle_call(:get_all_users, _from, state) do
    {:reply, state.users, state}
  end

  def handle_call(:get_all_messages, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_cast({:send_message, user_id_from, user_id_to, content}, state) do
    case user_exists(user_id_from, user_id_to, state) do
      {:error, response} ->
        IO.puts(response)
        {:noreply, state}

      {:ok} ->
        message = %{user_id_from: user_id_from,
                    from: Map.get(state.users, user_id_from),
                    to: Map.get(state.users, user_id_to),
                    user_id_to: user_id_to,
                    content: content}
        messages = [message | state.messages]
        Messages.handle_message(:sent)
        {:noreply, %{state | messages: messages}}
    end
  end

  def handle_cast({:receive_messages, user_id}, state) do
    state.messages
    |> Enum.filter(fn
      %{
        user_id_to: user_id_to
      } when user_id_to == user_id -> true
      _ -> false
    end)
    |> Enum.each(fn message ->
      Messages.handle_message(:received,
                              Map.get(state.users, message.user_id_from),
                              Map.get(state.users, user_id), message.content)
    end)
    {:noreply, state}
  end

  def handle_cast({:add_user, user_id, username}, state) do
    users = Map.put(state.users, user_id, username)
    Messages.handle_message(:created, username)
    {:noreply, %{state | users: users}}
  end

  def handle_cast({:remove_user, user_id}, state) do
    users = Map.delete(state.users, user_id)
    Messages.handle_message(:deleted, state.users[user_id])
    {:noreply, %{state | users: users}}
  end
end




# message_data3 = %{user_from: "chrystian",
# user_id_from: 1,
# user_to: "gabi",
# user_id_to: 3,
# content: "Hello Gabi!"
# }
message_data2 = %{user_from: "gabi",
user_id_from: 2,
user_to: "chrystian",
user_id_to: 1,
content: "Hello Chrystian!"
}
ChatServer.add_user(1, "chrystian")
