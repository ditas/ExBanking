defmodule ExBankingApp do
    use Application

    def start(_type, _args) do
        ExBanking.Supervisor.start_link()
    end
end