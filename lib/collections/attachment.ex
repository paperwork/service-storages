defmodule Paperwork.Collections.Attachment do
    require Logger

    @collection "attachments"
    @privates []
    @enforce_keys []
    @type t :: %__MODULE__{
        id: BSON.ObjectId.t() | nil,
        note_id: String.t(),
        filename: String.t(),
        content_type: String.t(),
        created_at: DateTime.t(),
        updated_at: DateTime.t(),
        deleted_at: DateTime.t() | nil
    }
    defstruct \
        id: nil,
        note_id: "",
        filename: "",
        content_type: "",
        created_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now(),
        deleted_at: nil

    use Paperwork.Collections

    @spec show(id :: BSON.ObjectId.t) :: {:ok, %__MODULE__{}} | {:notfound, nil}
    def show(%BSON.ObjectId{} = id) when is_map(id) do
        show(%__MODULE__{:id => id})
    end

    @spec show(id :: String.t) :: {:ok, %__MODULE__{}} | {:notfound, nil}
    def show(id) when is_binary(id) do
        show(%__MODULE__{:id => id})
    end

    @spec show(model :: __MODULE__.t) :: {:ok, %__MODULE__{}} | {:notfound, nil}
    def show(%__MODULE__{:id => _} = model) do
        collection_find(model, :id)
        |> strip_privates
    end

    @spec list() :: {:ok, [%__MODULE__{}]} | {:notfound, nil}
    def list() do
        %{}
        |> collection_find(true)
        |> strip_privates
    end

    def create(%{id: id, note_id: note_id, filename: filename, content_type: content_type} = attachment, global_id) when is_binary(note_id) and is_binary(filename) and is_binary(content_type) and is_map(attachment) and is_binary(global_id) do
        %__MODULE__{
            id: id,
            note_id: note_id,
            filename: filename,
            content_type: content_type,
            created_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now(),
            deleted_at: nil
        }
        |> collection_insert_with_id
        |> strip_privates

    end
end
