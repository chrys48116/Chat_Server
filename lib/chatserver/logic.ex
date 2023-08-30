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
        username = Map.get(state.users, user_id, "Unknown")
        rooms = Map.put(state.rooms, room_name, [{user_id, username} | room_users])
        IO.puts("User #{username} joined #{room_name}")
        {:noreply, %{state | rooms: rooms}}
    end
  end

  def send_group_message(room_name, user_id_from, content, state) do
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
        Enum.each(room_users, fn {user_id, username} ->
          IO.puts("Message sent to User #{user_id} #{username}: #{content}")
        end)
        {:noreply, new_state}
    end
  end

  def send_message(user_id_from, user_id_to, content, state) do
    case user_exists(user_id_from, user_id_to, state) do
      {:error, error} ->
        IO.puts(error)
        {:noreply, state}

      {:ok} ->
        new_message = %{user_id_from: user_id_from, user_id_to: user_id_to, content: content, timestamp: DateTime.utc_now()}
        state_message = %{state | messages: [new_message | state.messages]}
        new_state = %{state_message | pending_messages: [new_message | state.pending_messages]}

        # Notify the user that a new message has been sent
        IO.puts("Message sent to User #{Map.get(state.users, user_id_to)}: #{content}")
        {:noreply, new_state}
    end
  end

  def receive_messages(room_name, state) do
    Map.get(state.room_messages, room_name, [])
    |> Enum.each(fn message ->
      IO.puts("Received message from User_#{message.user_id_from} at #{message.timestamp}: #{message.content}")
    end)
  {:noreply, state}
  end

  def get_pending_messages(user_id, state) do
    {messages_to_user, remaining_messages} =
      Enum.split_with(state.pending_messages, fn message ->
        message.user_id_to == user_id
      end)

    Enum.each(messages_to_user, fn message ->
      IO.puts("Received message from #{Map.get(state.users, message.user_id_from)} at #{message.timestamp}: #{message.content}")
    end)
    new_state = %{state | pending_messages: remaining_messages}
    {:noreply, new_state}
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
