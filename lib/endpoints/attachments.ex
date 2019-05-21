defmodule Paperwork.Storages.Endpoints.Attachments do
    require Logger
    use Paperwork.Storages.Server
    use Paperwork.Helpers.Response

    pipeline do
        plug Paperwork.Auth.Plug.SessionLoader
    end

    namespace :attachments do

        get do
            global_id =
                conn
                |> Paperwork.Auth.Session.get_global_id()

            response = case \
                conn
                |> Paperwork.Auth.Session.get_user_role \
            do
                :role_admin ->
                    Paperwork.Collections.Attachment.list()
                _ ->
                    {:unauthorized, %{status: 1, content: "Not allowed to list all attachments!"}}
            end

            conn
            |> resp(response)
        end

        desc "Create Attachment"
        params do
            requires :note_id,     type: String
            requires :file,        type: File
        end
        post do
            global_id =
                conn
                |> Paperwork.Auth.Session.get_global_id()

            note_id =
                params[:note_id]

            file =
                params[:file]

            # TODO: Perform internal request to note_id and check whether note.access contains global_id and whether it has can_write == true

            pre_generated_id =
                Mongo.object_id()

            with \
                {:ok, _} <- Paperwork.Storages.S3.bucket_create(note_id),
                {:ok, _} <- Paperwork.Storages.S3.object_upload(file.path, note_id, pre_generated_id |> BSON.ObjectId.encode!()) do
                    response =
                        params
                        |> Map.put(:id, pre_generated_id)
                        |> Map.put(:filename, file.filename)
                        |> Map.put(:content_type, file.content_type)
                        |> Paperwork.Collections.Attachment.create(global_id)

                    conn
                    |> resp(response)
            else
                _ ->
                    # TODO: Remove the database entry
                    conn
                    |> resp({:error, %{status: 1, content: "Could not upload file to internal storage!"}})
            end
        end

        route_param :id do
            get do
                global_id =
                    conn
                    |> Paperwork.Auth.Session.get_global_id()

                response =
                    params[:id]
                    |> Paperwork.Collections.Attachment.show()

                {:ok, attachment} = response

                # TODO: Perform internal request to response.note_id and check whether note.access contains global_id and whether it has can_read == true

                case Paperwork.Storages.S3.object_download(attachment.note_id, attachment.id |> BSON.ObjectId.encode!()) do
                    {:ok, tmpfile} ->
                        conn
                        |> put_resp_content_type(attachment.content_type)
                        |> put_resp_header("content-disposition", "attachment; filename=#{attachment.filename}")
                        |> send_file(200, tmpfile)
                    other ->
                        Logger.error(other)
                        conn
                        |> resp({:error, %{status: 1, content: "Could not download file from internal storage!"}})
                end
            end

        end

    end
end
