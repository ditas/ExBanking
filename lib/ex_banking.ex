defmodule ExBanking do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(state) do
        {:ok, Map.put(state, :users, [])}
    end

    #################### Call ####################
    def handle_call({:create_user, user_name}, _from, state) when is_bitstring(user_name) do
        current_users = Map.get(state, :users)

#        :timer.sleep(4000)

        IO.inspect(current_users)

        {reply, state1} = case List.keymember?(current_users, user_name, 0) do
            true -> {{:error, :user_already_exists}, state}
            false ->
                try do
                    {:ok, pid} = User.start(user_name)
                    Process.monitor(pid)
                    {:ok, Map.put(state, :users, [{user_name, pid}|current_users])}
                rescue
                    e in ArgumentError -> {{:error, :wrong_arguments}, state}
                end
        end
        {:reply, reply, state1}
    end
    def handle_call({:create_user, _user_name}, _from, state) do
        {:reply, {:error, :wrong_arguments}, state}
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast({:test, user_name}, state) do

#        :timer.sleep(4000)

        current_users = Map.get(state, :users)
        {_, pid} = List.keyfind(current_users, user_name, 0)

        :erlang.process_info(pid, :message_queue_len) |> IO.inspect

        {_, q_len} = Process.info(pid, :message_queue_len)
        case q_len + 1 <= 2 do
            true -> User.user_test(pid)
            false -> IO.puts("TO MANY REQUESTS!")
        end

        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def create_user(user_name) do
        GenServer.call(__MODULE__, {:create_user, user_name})
        IO.puts("TEST0")
    end

    def test(user_name) do
        GenServer.cast(__MODULE__, {:test, user_name})
        IO.puts("TEST STARTED")
    end
end