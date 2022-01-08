# frozen_string_literal: true

RSpec.describe Cocoro::Device do
  subject(:device) { described_class.parse_box_info(input, client).first }
  let(:input) do
    [
      {
        "boxId" => "https://db.cloudlabs.sharp.co.jp/clpf/key/00000000000000000000000000000",
        "echonetData" => [{
          "maker" => "SHARP",
          "model" => "KILS70",
          "echonetNode" => "84-30-95-01-01-01",
          "echonetObject" => "010101",
          "deviceId" => 1_000_000,
          "labelData" => {
            "place" => "リビング",
            "name" => "Josh",
            "deviceType" => "AIR_CLEANER"
          }
        }]
      }
    ]
  end
  let(:client) { Cocoro::Client.new(app_secret: "foo", terminal_app_id_key: "bar") }

  its(:client) { is_expected.to eq(client) }
  its(:box_id) { is_expected.to match(/sharp\.co\.jp/) }
  its(:device_id) { is_expected.to eq(1_000_000) }
  its(:echonet_node) { is_expected.to eq("84-30-95-01-01-01") }
  its(:echonet_object) { is_expected.to eq("010101") }
  its(:name) { is_expected.to eq("Josh") }
  its(:type) { is_expected.to eq("AIR_CLEANER") }
  its(:maker) { is_expected.to eq("SHARP") }
  its(:model) { is_expected.to eq("KILS70") }
end
