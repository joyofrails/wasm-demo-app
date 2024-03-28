namespace :wasm do
  desc "Upload WebAssembly files to S3"
  task upload: :environment do
    UploadWasmJob.perform_now
  end
end
