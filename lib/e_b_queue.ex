defmodule EBQueue do
    use GenServer

    @queue_limit 2

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
                queue1 = [{message, self(), from}|queue]
                state1 = Map.put(state, :queue, queue1)
                User.execute(Map.get(state, :user), queue1)
                {:noreply, state1}
            false ->
                {:reply, {:error, :too_many_requests_to_user}, state}
        end
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast({:user_reply, reply, client}, state) do
        GenServer.reply(client, reply)
        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end
end