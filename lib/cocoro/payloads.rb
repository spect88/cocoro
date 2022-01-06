# frozen_string_literal: true

module Cocoro
  PAYLOADS = {
    power_on: {
      false => [{
        statusCode: "80",
        valueType: "valueSingle",
        valueSingle: {
          code: "31"
        }
      }, {
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "000300000000000000000000000000000000000000000000000000"
        }
      }],
      true => [{
        statusCode: "80",
        valueType: "valueSingle",
        valueSingle: {
          code: "30"
        }
      }, {
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "00030000000000000000000000FF00000000000000000000000000"
        }
      }]
    },
    humidifier_on: {
      false => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "000900000000000000000000000000000000000000000000000000"
        }
      }],
      true => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "000900000000000000000000000000FF0000000000000000000000"
        }
      }]
    },
    air_volume: {
      "auto" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100001000000000000000000000000000000000000000000000"
        }
      }],
      "night" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100001100000000000000000000000000000000000000000000"
        }
      }],
      "pollen" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100001300000000000000000000000000000000000000000000"
        }
      }],
      "quiet" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100001400000000000000000000000000000000000000000000"
        }
      }],
      "medium" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100001500000000000000000000000000000000000000000000"
        }
      }],
      "strong" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100001600000000000000000000000000000000000000000000"
        }
      }],
      "omakase" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010000002000000000000000000000000000000000000000000000"
        }
      }],
      "powerful" => [{
        statusCode: "f3",
        valueType: "valueBinary",
        valueBinary: {
          code: "010100004000000000000000000000000000000000000000000000"
        }
      }]
    }
  }.freeze
end
