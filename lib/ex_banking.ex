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
                    {:ok, pid} = EBQueue.start(user_name)
                    Process.monitor(pid)
                    :ets.insert(@ets_table, {user_name, pid})
                    :ok
                rescue
                    e in ArgumentError -> {:error, e}
                end
        end
    end
    def create_user(_user_name) do
        {:error, :wrong_arguments}
    end

    def test(user_name, message) do
        try_execute(user_name, message)
    end

    defp try_execute(user_name, message) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid}|_] when pid != :undefined ->
                GenServer.call(pid, message)
                    |> IO.inspect()
            _ ->
                {:error, :user_does_not_exist}
        end
    end

#    def deposit(user_name, amount, currency) when is_number(amount) do
#        try_execute(user_name, {:deposit, float_round(amount), currency})
#    end
#    def deposit(_user_name, _amount, _currency) do
#        {:error, :wrong_arguments}
#    end
#
#    def withdraw(user_name, amount, currency) when is_number(amount) do
#        try_execute(user_name, {:withdraw, float_round(amount), currency})
#    end
#    def withdraw(_user_name, _amount, _currency) do
#        {:error, :wrong_arguments}
#    end
#
#    def get_balance(user_name, currency) do
#        try_execute(user_name, {:get_balance, currency})
#    end
#
#    def send(from_user, to_user, amount, currency) when is_number(amount) do
#        do_send(from_user, to_user, float_round(amount), currency)
#            |> IO.inspect()
#    end
#    def send(_from_user, _to_user, _amount, _currency) do
#        {:error, :wrong_arguments}
#    end
#
#    def clear() do
#        :ets.delete_all_objects(@ets_table)
#    end

    #################### Internal functions ####################
#    defp try_execute(user_name, message) do
#        case :ets.lookup(@ets_table, user_name) do
#            [{user_name, pid, queue}|_] when pid != :undefined ->
#
#                IO.inspect(length(queue))
#
#                case length(queue) < @queue_limit do
#                    true ->
#                        queue1 = [message|queue]
#                        :ets.insert(@ets_table, {user_name, pid, queue1})
#                        case User.execute(pid, queue1) do
#                            {{:ok, reply}, queue2} ->
#                                :ets.insert(@ets_table, {user_name, pid, queue2})
#                                {:ok, reply}
#                            {error, queue2} ->
#                                :ets.insert(@ets_table, {user_name, pid, queue2})
#                                error
#                        end
#                    false ->
#                        {:error, :too_many_requests_to_user}
#                end
#            _ ->
#                {:error, :user_does_not_exist}
#        end
#    end
#
#    defp execute(user_name, message) do
#        [{user_name, pid, _queue}|_] = :ets.lookup(@ets_table, user_name)
#        User.execute(pid, [message])
#    end
#
#    defp do_send(from_user, to_user, amount, currency) do
#        case :ets.lookup(@ets_table, from_user) do
#            [{from_user, from_pid, from_queue}|_] when from_pid != :undefined ->
#                case :ets.lookup(@ets_table, to_user) do
#                    [{to_user, to_pid, to_queue}|_] when to_pid != :undefined ->
#                        case length(from_queue) < @queue_limit do
#                            true ->
#                                case length(to_queue) < @queue_limit do
#                                    true ->
##                                        :ok
#                                        case execute(from_user, {:withdraw, amount, currency}) do
#                                            {{:ok, [new_balance: from_balance]}, _queue} ->
#                                                case execute(to_user, {:deposit, amount, currency}) do
#                                                    {{:ok, [new_balance: to_balance]}, _queue} ->
#                                                        {:ok, from_user_balance: from_balance, to_user_balance: to_balance}
#                                                    {error, _queue} -> # TODO: not sure it's okay
#                                                        error
#                                                end
#                                            {error, _queue} ->
#                                                error
#                                        end
#                                    false ->
#                                        {:error, :too_many_requests_to_receiver}
#                                end
#                            false ->
#                                {:error, :too_many_requests_to_sender}
#                        end
#                    _ ->
#                        {:error, :receiver_does_not_exist}
#                end
#            _ ->
#                {:error, :sender_does_not_exist}
#        end
#    end
#
#    defp float_round(number) when is_float(number) do
#        Float.round(number, 2)
#    end
#    defp float_round(number) when is_integer(number) do
#        Float.round(number*1.00, 2)
#    end

end