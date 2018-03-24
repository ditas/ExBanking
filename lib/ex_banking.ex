defmodule ExBanking do
    use GenServer

    @ets_table :users

    def start_link() do
    
        IO.puts("------0")
        
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_) do
        
        IO.puts("------1")
        
        @ets_table = :ets.new(@ets_table, [:set, :protected, :named_table])

        IO.puts("------2")
        
        {:ok, []}
    end

    #################### Call ####################
    def handle_call(:test1, _from, state) do
        {:reply, {:test1}, state}
    end
#    def handle_call({:create_user, user_name}, _from, state) when is_bitstring(user_name) do
#        current_users = Map.get(state, :users)
#
##        IO.inspect(current_users)
#
#        {reply, state1} = case List.keymember?(current_users, user_name, 0) do
#            true -> {{:error, :user_already_exists}, state}
#            false ->
#                try do
#                    {:ok, pid} = User.start(user_name)
#                    Process.monitor(pid)
#                    {:ok, Map.put(state, :users, [{user_name, pid}|current_users])}
#                rescue
#                    e in ArgumentError -> {{:error, :wrong_arguments}, state}
#                end
#        end
#        {:reply, reply, state1}
#    end
#    def handle_call({:create_user, _user_name}, _from, state) do
#        {:reply, {:error, :wrong_arguments}, state}
#    end
#    def handle_call({:test, user_name}, _from, state) do
#        current_users = Map.get(state, :users)
#        {_, pid} = List.keyfind(current_users, user_name, 0)
#
#        :erlang.process_info(pid, :message_queue_len) |> IO.inspect
#        reply = User.user_test(pid)
##                |> IO.inspect()
#
#        {:reply, reply, state}
#    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def create_user(user_name) when is_bitstring(user_name) do
#        GenServer.call(__MODULE__, {:create_user, user_name})
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid}|_] when pid != :undefined ->
                {:error, :user_already_exists}
            _ ->
                try do
                    {:ok, pid} = User.start(user_name)
                    Process.monitor(pid)
                    :ets.insert(@ets_table, {user_name, pid})
                    :ok
                rescue
                    e in ArgumentError -> {:error, e}
                end
        end
    end
    def create_user(user_name) do
        {:error, :wrong_arguments}
    end

    def test(user_name) do
#        GenServer.call(__MODULE__, {:test, user_name})
        case :ets.lookup(@ets_table, user_name) do
            [{_, pid}|_] when pid != :undefined ->
                :erlang.process_info(pid, :message_queue_len) |> IO.inspect
                reply = User.user_test(pid)
#                    |> IO.inspect()
                reply
            _ ->
                {:error, :oops!}
        end
    end
end