use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :phoenix_chat, PhoenixChat.Endpoint,
# http: [port: 4000],
  url: [host: "phoenixchat.local", port: 4001],
  https: [port: 4001,
          otp_app: :phoenix_chat,
          keyfile: "../../../../priv/ssl/phoenixchat.local.key",
          certfile: "../../../../priv/ssl/phoenixchat.local.crt"
  #        #cacertfile: System.get_env(Path.expand("priv/ssl/gtcode.com.??", __DIR__)) # OPTIONAL Key for intermediate certificates
          ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin"]]

# Watch static and templates for browser reloading.
config :phoenix_chat, PhoenixChat.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :phoenix_chat, PhoenixChat.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phoenix_chat_dev",
  hostname: "localhost",
  pool_size: 10
