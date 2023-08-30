defmodule ChatServer.Logic do

  alias ChatServer.Messages
  def user_exists(user_id_from, user_id_to, state) do
    case {Map.get(state.users, user_id_from), Map.get(state.users, user_id_to)} do
      {nil, _} ->  {:error, "User with id #{user_id_from} not found"}
      {_, nil} ->  {:error, "User with id #{user_id_to} not found"}
      {_, _} -> {:ok}
    end
  end

  def join_room(user_id, room_name, state) do
    case Map.get(state.rooms, room_name) do
      nil ->
        IO.puts("Room does not exists")
        {:noreply, state}

      room_users ->
        rooms = Map.put(state.rooms, room_name, [user_id | room_users])
        {:noreply, %{state | rooms: rooms}}
    end
  end

  def send_message(room_name, user_id_from, content, state) do
    case Map.get(state.rooms, room_name) do
      nil ->
        IO.puts("Room does not exist.")
        {:noreply, state}

      room_users ->
        new_message = %{user_id_from: user_id_from, content: content, room: room_name, timestamp: DateTime.utc_now()}

        room_messages = Map.get(state.room_messages, room_name, [])
        new_room_messages = [new_message | room_messages]

        new_state = %{state | room_messages: Map.put(state.room_messages, room_name, new_room_messages)}

        # Notify all users in the room about the new message
        Enum.each(room_users, fn user_id ->
          if user_id != user_id_from do
            IO.puts("Message sent to User #{user_id}: #{content}")
          end
        end)

        {:noreply, new_state}
    end
  end

  def receive_messages(room_name, state) do
    messages_in_room = Map.get(state.room_messages, room_name, [])
  Enum.each(messages_in_room, fn message ->
    IO.puts("Received message from User_#{message.user_id_from}: #{message.content}")
  end)
  {:noreply, state}
  end

  def add_user(user_id, username, state) do
    users = Map.put(state.users, user_id, username)
    #Messages.handle_message(:created, username)
    {:noreply, %{state | users: users}}
  end

  def remove_user(user_id, state) do
    users = Map.delete(state.users, user_id)
    #Messages.handle_message(:deleted, state.users[user_id])
    {:noreply, %{state | users: users}}
  end
end
