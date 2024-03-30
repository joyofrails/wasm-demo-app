module CloudStorage
  class Api
    Result = Struct.new(:data, :error, keyword_init: true) do
      def success?
        error.nil?
      end
    end

    def initialize(bucket_name)
      @bucket_name = bucket_name
    end

    def exists?(cloud_path)
      data = bucket.files.head(cloud_path)
      Result.new(data: data)
    end

    def upload(options = {})
      data = bucket.files.create(options)
      Result.new(data: data)
    end

    def bucket
      @bucket ||= s3.directories.get(@bucket_name)
    end

    def s3
      @s3 ||= begin
        require "fog/aws"
        Fog::Storage.new(
          provider: "AWS",
          aws_access_key_id: Rails.application.credentials.aws.access_key_id,
          aws_secret_access_key: Rails.application.credentials.aws.secret_access_key
        )
      end
    end

    private
  end
end
