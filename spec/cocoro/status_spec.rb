# frozen_string_literal: true

RSpec.describe Cocoro::Status do
  subject(:status) { described_class.new(input) }
  let(:input) do
    [
      {
        "statusCode" => "F1",
        "valueType" => "valueBinary",
        "valueSingle" => nil,
        "valueRange" => nil,
        "valueBinary" => { "code" => f1 }
      },
      {
        "statusCode" => "F2",
        "valueType" => "valueBinary",
        "valueSingle" => nil,
        "valueRange" => nil,
        "valueBinary" => { "code" => f2 }
      },
      {
        "statusCode" => "F3",
        "valueType" => "valueBinary",
        "valueSingle" => nil,
        "valueRange" => nil,
        "valueBinary" => { "code" => f3 }
      }
    ]
  end
  let(:f1) do
    [
      "6201D8", # 1-3: unknown
      "16", # 4: temperature
      "30", # 5: humidity
      "02FE00F0000000001C76007800000079", # 6-21: unknown
      "0000346A", # 22-25: total air cleaned
      "0000", # 26-27: unknown
      pm25_bytes, # 28-29: pm25 (only last 9 bits)
      "0000000000000005050008" # 30-40: unknown
    ].join
  end
  let(:pm25_bytes) { "0000" }
  let(:f2) do
    [
      "0060000000000000000000000000", # 1-14: unknown
      "00", # 15: odor
      "00", # 16: dust
      "00", # 17: unknown
      "00", # 18: overall dirtiness
      "00", # 19: unknown
      "FF", # 20: enough water
      "FF", # 21: light detected
      "00000081FF0014010000000000000000000000" # 22-40: unknown
    ].join
  end
  let(:f3) do
    [
      "00000000", # 1-4: unknown
      "14", # 5: air volume (aka mode)
      "0000008000000000", # 6-13: unknown
      "FF", # 14: power on
      "00", # 15: unknown
      "FF", # 16: humidifier on
      "0000000000000000000000" # 17-27: unknown
    ].join
  end

  its(:enough_water?) { is_expected.to eq(true) }
  its(:light_detected?) { is_expected.to eq(true) }
  its(:power_on?) { is_expected.to eq(true) }
  its(:humidifier_on?) { is_expected.to eq(true) }

  its(:temperature) { is_expected.to eq(22) }
  its(:humidity) { is_expected.to eq(48) }
  its(:total_air_cleaned) { is_expected.to eq(13_418) }
  its(:pm25) { is_expected.to eq(0) }
  its(:odor) { is_expected.to eq(0) }
  its(:dust) { is_expected.to eq(0) }
  its(:overall_dirtiness) { is_expected.to eq(0) }
  its(:air_volume) { is_expected.to eq("quiet") }

  its(:to_h) { is_expected.to include(:power_on, :pm25, :air_volume, :f1) }

  context "when the hex value for PM2.5 is larger than 512" do
    let(:pm25_bytes) { "8001" }

    it "only takes the last 9 bits (up to 511)" do
      expect(status.pm25).to eq(1)
    end
  end
end
