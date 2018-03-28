defmodule ExBanking do
    use GenServer

    @ets_table :users
    @queue_limit 2

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
        try_execute(user_name, {:deposit, amount, currency})
    end
    def deposit(_user_name, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    def withdraw(user_name, amount, currency) when is_number(amount) do
        try_execute(user_name, {:withdraw, amount, currency})
    end
    def withdraw(_user_name, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    #################### Internal functions ####################
    defp try_execute(user_name, message) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid, queue}|_] when pid != :undefined ->

                IO.inspect(length(queue))

                case length(queue) < @queue_limit do
                    true ->
                        queue1 = [message|queue]
                        :ets.insert(@ets_table, {user_name, pid, queue1})
                        case User.execute(pid, queue1) do
                            {{:ok, reply}, queue2} ->
                                :ets.insert(@ets_table, {user_name, pid, queue2})
                                {:ok, reply}
                            {error, _queue2} ->
                                error
                        end
                    false ->
                        {:error, :too_many_requests_to_user}
                end
            _ ->
                {:error, :user_does_not_exist}
        end
    end
end