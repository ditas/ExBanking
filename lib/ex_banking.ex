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

    def get_balance(user_name, currency) do
        try_execute(user_name, {:get_balance, currency})
    end

    def send(from_user, to_user, amount, currency) when is_number(amount) do
        case try_execute(from_user, {:withdraw, amount, currency}) do
            {:ok, [new_balance: from_balance]} ->
                case try_execute(to_user, {:deposit, amount, currency}) do
                    {:ok, [new_balance: to_balance]} ->
                        {:ok, from_user_balance: from_balance, to_user_balance: to_balance}
                    {:error, :user_does_not_exist} ->
                        {:error, :receiver_does_not_exist}
                    {:error, :too_many_requests_to_user} ->
                        {:error, :too_many_requests_to_receiver}
                    error ->
                        error
                end
            {:error, :user_does_not_exist} ->
                {:error, :sender_does_not_exist}
            {:error, :too_many_requests_to_user} ->
                {:error, :too_many_requests_to_sender}
            error ->
                error
        end
    end
    def send(_from_user, _to_user, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    def clear() do
        :ets.delete_all_objects(@ets_table)
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
                            {{:error, :too_many_requests_to_user} = error, _queue2} ->
                                error
                            {error, queue2} ->
                                :ets.insert(@ets_table, {user_name, pid, queue2})
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