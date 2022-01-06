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
        "valueBinary" => {
          "code" => <<~HEX.gsub(/\s+/, "")
            6201D8163002FE00F0000000001C760078000000790000346A000000000000000000000005050008
          HEX
        }
      },
      {
        "statusCode" => "F2",
        "valueType" => "valueBinary",
        "valueSingle" => nil,
        "valueRange" => nil,
        "valueBinary" => {
          "code" => <<~HEX.gsub(/\s+/, "")
            00600000000000000000000000000000000000FFFF00000081FF0014010000000000000000000000
          HEX
        }
      },
      {
        "statusCode" => "F3",
        "valueType" => "valueBinary",
        "valueSingle" => nil,
        "valueRange" => nil,
        "valueBinary" => {
          "code" => <<~HEX.gsub(/\s+/, "")
            00000000140000008000000000FF00FF0000000000000000000000
          HEX
        }
      }
    ]
  end

  its(:enough_water?) { is_expected.to eq(true) }
  its(:light_detected?) { is_expected.to eq(true) }
  its(:power_on?) { is_expected.to eq(true) }
  its(:humidifier_on?) { is_expected.to eq(true) }

  its(:temperature) { is_expected.to eq(22) }
  its(:humidity) { is_expected.to eq(48) }
  its(:total_air_cleaned) { is_expected.to eq(13_418) }
  its(:pm25) { is_expected.to eq(0) }
  its(:smell) { is_expected.to eq(0) }
  its(:dust) { is_expected.to eq(0) }
  its(:overall_cleanliness) { is_expected.to eq(0) }
  its(:air_volume) { is_expected.to eq("quiet") }

  its(:to_h) { is_expected.to include(:power_on, :pm25, :air_volume, :f1) }
end
