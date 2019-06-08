defmodule Paperwork.Storages.Endpoints.ProfilePhotos do
    require Logger
    use Paperwork.Storages.Server
    use Paperwork.Helpers.Response

    pipeline do
        plug Paperwork.Auth.Plug.SessionLoader
    end

    namespace :profile_photos do

        get do
            global_id =
                conn
                |> Paperwork.Auth.Session.get_global_id()

            response = case \
                conn
                |> Paperwork.Auth.Session.get_user_role \
            do
                :role_admin ->
                    Paperwork.Collections.ProfilePhoto.list()
                _ ->
                    {:unauthorized, %{status: 1, content: "Not allowed to list all profile_photos!"}}
            end

            conn
            |> resp(response)
        end

        desc "Create ProfilePhoto"
        params do
            requires :file,        type: File
        end
        post do
            global_id =
                conn
                |> Paperwork.Auth.Session.get_global_id()

            file =
                params[:file]

            {:ok, %{"id" => user_id}} = Paperwork.Internal.Request.user(global_id)

            Mogrify.open(file.path)
            |> Mogrify.gravity("Center")
            |> Mogrify.resize_to_fill("1024x1024")
            |> Mogrify.format("png")
            |> Mogrify.save(in_place: true)

            pre_generated_id =
                Mongo.object_id()

            with \
                {:ok, _} <- Paperwork.Storages.S3.bucket_create(user_id),
                {:ok, _} <- Paperwork.Storages.S3.object_upload(file.path, user_id, pre_generated_id |> BSON.ObjectId.encode!()) do
                    response =
                        params
                        |> Map.put(:id, pre_generated_id)
                        |> Map.put(:user_id, user_id)
                        |> Paperwork.Collections.ProfilePhoto.create(global_id)
                        |> Paperwork.Helpers.Journal.api_response_to_journal(params, :create, :profile_photo, :user, global_id, [global_id |> Paperwork.Id.from_gid()])

                    # TODO: Check database for previous profile photo for this user and remove from database and from storage?

                    conn
                    |> resp(response)
            else
                _ ->
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
                    |> Paperwork.Collections.ProfilePhoto.show()

                {:ok, profile_photo} = response

                profile_photo_id =
                    profile_photo.id
                    |> BSON.ObjectId.encode!()

                {:ok, tmpfile} = Briefly.create

                case Paperwork.Storages.S3.object_download(profile_photo.user_id, profile_photo_id, tmpfile) do
                    {:ok, _} ->
                        conn
                        |> put_resp_content_type("image/png")
                        |> put_resp_header("content-disposition", "profile_photo; filename=#{profile_photo_id}")
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
