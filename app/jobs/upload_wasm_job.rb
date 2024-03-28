class UploadWasmJob < ApplicationJob
  queue_as :default

  def perform(*args)
    cloud_api = CloudStorage::Api.new("rails-wasm")

    app_version = WasmDemo::VERSION
    rails_version = Rails.version.split(".").take(2).join(".")
    ruby_version = RUBY_VERSION.split(".").take(2).join(".")
    base_path = "wasm-demo-app/#{Rails.env.local? ? "#{Rails.env}/" : ""}#{app_version}"

    [
      "ruby-#{ruby_version}-web.wasm",
      "rails-#{rails_version}-ruby-#{ruby_version}-web.wasm"
    ].each do |file|
      s3_key = "#{base_path}/#{file}"
      exists_result = cloud_api.exists?(s3_key)
      puts "[#{self.class}] s3_object head for key #{s3_key}: #{exists_result.data.inspect}"

      if exists_result.data.present?
        puts "[#{self.class}] File upload already exists: #{s3_key}"
      else
        local_file = ".wasm/#{file}"
        raise "File not found: #{local_file}" if !File.exist?(local_file)

        puts "[#{self.class}] File uploading #{s3_key.inspect} #{local_file.inspect}"
        result = cloud_api.upload(s3_key, local_file)
        puts "[#{self.class}] File upload result #{local_file.inspect}\n#{result.inspect}"
      end
    end
  end
end
