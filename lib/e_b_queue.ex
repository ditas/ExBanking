defmodule EBQueue do
    use GenServer

    @queue_limit 10

    def start(_name) do
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, pid} = User.start()
        {:ok, Map.put(state, :queue, [])
              |> Map.put(:user, pid)}
    end

    #################### Call ####################
    def handle_call(message, from, state) do
        queue = Map.get(state, :queue)
            |> IO.inspect()
        case length(queue) < @queue_limit do
            true ->
                ref = :erlang.make_ref()
                queue1 = [{message, self(), from, ref}|queue]
#                    |> IO.inspect()
                state1 = Map.put(state, :queue, queue1)
#                    |> IO.inspect()

                [h|t] = :lists.reverse(queue1)
                User.execute(Map.get(state, :user), h)
                {:noreply, state1}
            false ->
                {:reply, {:error, :too_many_requests_to_user}, state}
        end
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast({:user_reply, reply, client, ref}, state) do
        GenServer.reply(client, reply)
#            |> IO.inspect()

        queue = Map.get(state, :queue)
        queue1 = :lists.keydelete(ref, 4, queue)
        {:noreply, Map.put(state, :queue, queue1)}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end
end