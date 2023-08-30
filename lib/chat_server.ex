defmodule ChatServer do
  use GenServer
  alias ChatServer.Logic

  def start_link(_), do: GenServer.start_link(__MODULE__, initial_state(), name: __MODULE__)

  defp initial_state(), do: %{rooms: %{}, users: %{}, messages: [], pending_messages: [], room_messages: %{}}

  def init(init_arg), do: {:ok, init_arg}

  def get_all_users(), do: GenServer.call(__MODULE__, :get_all_users)

  def get_all_messages(), do: GenServer.call(__MODULE__, :get_all_messages)

  def get_all_chats(), do: GenServer.call(__MODULE__, :get_all_chats)

  def get_users_in_room(room_name), do: GenServer.call(__MODULE__, {:get_users_in_room, room_name})

  def get_messages_in_room(room_name), do: GenServer.call(__MODULE__, {:get_messages_in_room, room_name})

  def create_room(room_name), do: GenServer.cast(__MODULE__, {:create_room, room_name})

  def add_user(user_id, username), do: GenServer.cast(__MODULE__, {:add_user, user_id, username})

  def remove_user(user_id), do: GenServer.cast(__MODULE__, {:remove_user, user_id})

  def send_group_message(%{room_name: room_name, user_id_from: user_id_from, content: content}) do
    GenServer.cast(__MODULE__, {:send_group_message, room_name, user_id_from, content})
  end

  def send_message(%{user_id_from: user_id_from, user_id_to: user_id_to, content: content}) do
    GenServer.cast(__MODULE__, {:send_message, user_id_from, user_id_to, content})
  end

  def receive_messages(room_name), do: GenServer.cast(__MODULE__, {:receive_messages, room_name})

  def get_pending_messages(user_id), do: GenServer.cast(__MODULE__, {:get_pending_messages, user_id})

  def join_room(user_id, room_name), do: GenServer.cast(__MODULE__, {:join_room, user_id, room_name})

  def handle_call({:get_users_in_room, room_name}, _from, state), do: {:reply, Map.get(state.rooms, room_name, []), state}

  def handle_call({:get_messages_in_room, room_name}, _from, state) do
    {:reply, Map.get(state.room_messages, room_name, []), state}
  end

  def handle_call(:get_all_users, _from, state), do: {:reply, state.users, state}

  def handle_call(:get_all_messages, _from, state), do: {:reply, state.messages, state}

  def handle_call(:get_all_chats, _from, state), do: {:reply, state.rooms, state}

  def handle_cast({:create_room, room_name}, state) do
    room = Map.put(state.rooms, room_name, [])
    {:noreply, %{state | rooms: room}}
  end

  def handle_cast({:join_room, user_id, room_name}, state), do: Logic.join_room(user_id, room_name, state)

  def handle_cast({:send_group_message, room_name, user_id_from, content}, state) do
    Logic.send_group_message(room_name, user_id_from, content, state)
  end

  def handle_cast({:send_message, user_id_from, user_id_to, content}, state) do
    Logic.send_message(user_id_from, user_id_to, content, state)
  end

  def handle_cast({:receive_messages, room_name}, state), do: Logic.receive_messages(room_name, state)

  def handle_cast({:get_pending_messages, user_id}, state) do
    Logic.get_pending_messages(user_id, state)
  end

  def handle_cast({:add_user, user_id, username}, state), do: Logic.add_user(user_id, username, state)

  def handle_cast({:remove_user, user_id}, state), do: Logic.remove_user(user_id, state)
end



# message_data3 = %{user_id_from: 1,
# user_id_to: 2,
# content: "Hello Gabi!"
# }
# message_data2 = %{user_from: "gabi",
# user_id_from: 2,
# user_to: "chrystian",
# user_id_to: 1,
# content: "Hello Chrystian!"
# }
# ChatServer.add_user(1, "chrystian")
# ChatServer.create_room("room")
# ChatServer.join_room(1, "room")

# send_message = %{
#   room_name: "room1",
#   user_id_from: 1,
#   content: "ola pessoal"
# }
