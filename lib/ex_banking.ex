defmodule ExBanking do
    use GenServer

    @ets_table :users

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_) do
        @ets_table = :ets.new(@ets_table, [:set, :public, :named_table])
        {:ok, []}
    end

    #################### Call ####################
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def create_user(user_name) when is_bitstring(user_name) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid, _queue}|_] when pid != :undefined ->
                {:error, :user_already_exists}
            _ ->
                try do
                    {:ok, pid} = User.start(user_name)
                    Process.monitor(pid)
                    :ets.insert(@ets_table, {user_name, pid, []})
                    :ok
                rescue
                    e in ArgumentError -> {:error, e}
                end
        end
    end
    def create_user(_user_name) do
        {:error, :wrong_arguments}
    end

    def deposit(user_name, amount, currency) when is_number(amount) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid, _queue}|_] when pid != :undefined ->
                User.deposit(pid, amount, currency)
            _ ->
                {:error, :user_does_not_exist}
        end
    end
    def deposit(_user_name, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    def withdraw(user_name, amount, currency) when is_number(amount) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid, queue}|_] when pid != :undefined and length(queue) <= 2 ->
#                reply = User.withdraw(pid, amount, currency)

                new_queue = [{:withdraw, amount, currency}|queue]
                :ets.insert(@ets_table, {user_name, pid, new_queue})
                User.execute(pid, new_queue)
            _ ->
                {:error, :user_does_not_exist}
        end
    end
    def withdraw(_user_name, _amount, _currency) do
        {:error, :wrong_arguments}
    end



    def test(user_name) do
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