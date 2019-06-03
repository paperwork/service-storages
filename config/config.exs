use Mix.Config

config :paperwork_service_storages, Paperwork.Storages.Server,
    adapter: Plug.Cowboy,
    plug: Paperwork.Storages,
    scheme: :http,
    ip: {0,0,0,0},
    port: {:system, :integer, "PORT", 8883}

config :paperwork_service_storages,
    maru_servers: [Paperwork.Storages.Server]

config :paperwork, :server,
    app: :paperwork_service_storages,
    cache_ttl_default: 86_400,
    cache_janitor_interval: 60

config :paperwork, :mongodb,
    url: {:system, :string, "MONGODB_URL", "mongodb://localhost:27017/storages"}

config :paperwork, :internal,
    cache_ttl: 60,
    configs:     {:system, :string, "INTERNAL_RESOURCE_CONFIGS",     "http://localhost:8880/internal/configs"},
    users:       {:system, :string, "INTERNAL_RESOURCE_USERS",       "http://localhost:8881/internal/users"},
    notes:       {:system, :string, "INTERNAL_RESOURCE_NOTES",       "http://localhost:8882/internal/notes"},
    attachments: {:system, :string, "INTERNAL_RESOURCE_ATTACHMENTS", "http://localhost:8883/internal/attachments"},
    journals:    {:system, :string, "INTERNAL_RESOURCE_JOURNALS",    "http://localhost:8884/internal/journals"}

config :ex_aws, :s3,
    debug_requests: true,
    access_key_id: "",
    secret_access_key: "",
    scheme: "",
    host: "",
    region: ""

config :briefly,
    default_prefix: "paperwork"

config :paperwork, :storage,
    endpoint: {:system, :string, "STORAGE_URL", "http://localhost:9000"},
    region: "",
    access_key_id: {:system, :string, "AWS_ACCESS_KEY_ID", "root"},
    secret_access_key: {:system, :string, "AWS_SECRET_ACCESS_KEY", "roooooot"}

config :logger,
    backends: [:console]
