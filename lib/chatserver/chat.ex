defmodule ChatServer.Chat do
  def start(user_id, room_name) do
    ChatServer.add_user(user_id, "User #{user_id}")
    ChatServer.create_room(room_name)
    ChatServer.join_room(user_id, room_name)

    IO.puts("User_#{user_id} joined #{room_name}")

    Task.async(fn -> receive_loop(user_id, room_name) end)
    send_loop(user_id, room_name)
  end

  defp send_loop(user_id, room_name) do
    :timer.sleep(1000)
    IO.puts("Type a message to send:")
    message = IO.gets(">")
    case message do
      "exit" ->
        IO.puts("User_#{user_id} left #{room_name}")
        ChatServer.remove_user(user_id)
        :ok
      _ ->
        ChatServer.send_message(%{room_name: room_name, user_id_from: user_id, content: message})
    end
    #ChatServer.receive_messages(room_name)
    send_loop(user_id, room_name)
  end

  defp receive_loop(user_id, room_name, last_message \\ nil) do
    ChatServer.get_messages_in_room(room_name)
    |> case do
      [latest_message | _tail] when latest_message !== last_message ->
        IO.puts("Received message from User_#{latest_message.user_id_from}: #{latest_message.content}")
        :timer.sleep(1000)
        receive_loop(user_id, room_name, latest_message)

      [latest_message | _tail] ->
        :timer.sleep(1000)
        receive_loop(user_id, room_name, last_message)

      [] ->
        #IO.puts("No messages received")
        :timer.sleep(5000)
        receive_loop(user_id, room_name, last_message)
    end
  end
end
