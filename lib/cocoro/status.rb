# frozen_string_literal: true

module Cocoro
  # Wrapper for device's status info format. Includes translation of the binary values.
  class Status
    LOCATIONS = {
      # key: [property code, byte_offset, byte_length]
      # Offset is 1-based because that's how logs API works too
      temperature: ["F1", 4, 1], # °C
      humidity: ["F1", 5, 1], # %
      total_air_cleaned: ["F1", 22, 4], # m^3
      pm25: ["F1", 28, 2], # ug/m^3, only last 9 bits are important
      odor: ["F2", 15, 1], # 0/33/66/100 (100=dirty)
      dust: ["F2", 16, 1], # 0/25/50/75/100 (100=dirty)
      overall_dirtiness: ["F2", 18, 1], # 0/25/50/75/100 (100=dirty)
      enough_water: ["F2", 20, 1],
      light_detected: ["F2", 21, 1],
      air_volume: ["F3", 5, 1],
      power_on: ["F3", 14, 1],
      humidifier_on: ["F3", 16, 1]
    }.freeze
    VALUES = {
      enough_water: { 0 => false, 255 => true },
      light_detected: { 0 => false, 255 => true },
      air_volume: {
        0 => nil,
        16 => "auto",
        17 => "night",
        19 => "pollen",
        20 => "quiet",
        21 => "medium",
        22 => "strong",
        32 => "omakase",
        64 => "powerful"
      },
      power_on: { 0 => false, 255 => true },
      humidifier_on: { 0 => false, 255 => true }
    }.freeze

    BOOLEAN_FIELDS = %i[enough_water light_detected power_on humidifier_on].freeze
    NON_BOOLEAN_FIELDS = %i[
      temperature humidity total_air_cleaned pm25 odor dust overall_dirtiness air_volume
    ].freeze

    def initialize(array_of_status_data)
      @array = array_of_status_data
    end

    BOOLEAN_FIELDS.each do |field|
      define_method(:"#{field}?") { read_value(field) }
    end

    NON_BOOLEAN_FIELDS.each do |field|
      define_method(field) { read_value(field) }
    end

    def to_h
      (BOOLEAN_FIELDS + NON_BOOLEAN_FIELDS)
        .map { |f| [f, read_value(f)] }
        .to_h
        .merge(
          f1: read_binary_status("F1"),
          f2: read_binary_status("F2"),
          f3: read_binary_status("F3")
        )
    end

    protected

    def read_value(name)
      code, byte_offset, byte_length = LOCATIONS[name]
      hex_code = read_binary_status(code)
      return nil if hex_code.nil?

      number = hex_code[(byte_offset - 1) * 2, byte_length * 2].to_i(16)
      if VALUES[name]&.key?(number)
        VALUES[name][number]
      elsif name == :pm25
        number & ((2**9) - 1) # last 9 bits only
      else
        number
      end
    end

    def read_binary_status(code)
      @array
        .find { |s| s["statusCode"] == code }
        &.dig("valueBinary", "code")
    end
  end
end
