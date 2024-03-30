require "rails_helper"

RSpec.describe UploadWasmJob, type: :job do
  let(:cloud_api) { instance_double(CloudStorage::Api) }

  before do
    allow($stdout).to receive(:write) # silence puts

    allow(CloudStorage::Api).to receive(:new).with("rails-wasm").and_return(cloud_api)
    allow(File).to receive(:exist?).and_return(true)
    allow(cloud_api).to receive(:exists?).and_return(double(data: nil)).twice
    allow(cloud_api).to receive(:upload).and_return(double(data: "data")).twice

    allow(File).to receive(:open).and_return(StringIO.new("data"))
  end

  it "uploads the wasm files" do
    described_class.perform_now

    expect(cloud_api).to have_received(:exists?).with(%r{^wasm-demo-app/test/[^/]*/ruby-\d\.\d-web.wasm$}).once
    expect(cloud_api).to have_received(:exists?).with(%r{^wasm-demo-app/test/[^/]*/rails-\d\.\d-ruby-\d\.\d-web.wasm$}).once
    expect(cloud_api).to have_received(:upload).with(:key => %r{^wasm-demo-app/test/[^/]*/ruby-\d\.\d-web.wasm$}, :body => kind_of(StringIO), :public => true, "Cache-Control" => "max-age=31536000", "Content-Type" => "application/wasm").once
    expect(cloud_api).to have_received(:upload).with(:key => %r{^wasm-demo-app/test/[^/]*/rails-\d\.\d-ruby-\d\.\d-web.wasm$}, :body => kind_of(StringIO), :public => true, "Cache-Control" => "max-age=31536000", "Content-Type" => "application/wasm").once
  end

  it "skips the wasm file upload" do
    allow(cloud_api).to receive(:exists?).and_return(double(data: true)).twice

    described_class.perform_now

    expect(cloud_api).to have_received(:exists?).with(%r{^wasm-demo-app/test/[^/]*/ruby-\d\.\d-web.wasm$}).once
    expect(cloud_api).to have_received(:exists?).with(%r{^wasm-demo-app/test/[^/]*/rails-\d\.\d-ruby-\d\.\d-web.wasm$}).once

    expect(cloud_api).not_to have_received(:upload)
  end
end
