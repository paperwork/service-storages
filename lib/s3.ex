defmodule Paperwork.Storages.S3 do
    def bucket_create(bucket) when is_binary(bucket) do
        case bucket
            |> ExAws.S3.put_bucket(Paperwork.Storages.storage_config()[:region])
            |> ExAws.request(Paperwork.Storages.storage_config()) \
        do
            {:ok, ret} -> {:ok, ret}
            {:error, {:http_error, 409, ret}} -> {:ok, ret} # BucketAlreadyOwnedByYou
            other -> other
        end
    end

    def object_upload(filepath, bucket, key) do
        case filepath
            |> ExAws.S3.Upload.stream_file()
            |> ExAws.S3.upload(bucket, key)
            |> ExAws.request(Paperwork.Storages.storage_config()) \
        do
            {:ok, ret} -> {:ok, ret}
            other -> other
        end
    end

    def object_download(bucket, key) do
        tmpfile = Plug.Upload.random_file!(key)
        case bucket
            |> ExAws.S3.download_file(key, tmpfile)
            |> ExAws.request(Paperwork.Storages.storage_config()) \
        do
            {:ok, ret} -> {:ok, tmpfile}
            other -> other
        end
    end
end
