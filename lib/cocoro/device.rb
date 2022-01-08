# frozen_string_literal: true

require_relative "status"
require_relative "payloads"

module Cocoro
  Device = Struct.new(
    :client,
    :box_id,
    :device_id,
    :echonet_node,
    :echonet_object,
    :name,
    :type,
    :maker,
    :model,
    keyword_init: true
  ) do
    def self.parse_box_info(box_info, client)
      box_info.flat_map do |box|
        box["echonetData"].map do |data|
          new(
            client: client,
            box_id: box["boxId"],
            device_id: data["deviceId"],
            echonet_node: data["echonetNode"],
            echonet_object: data["echonetObject"],
            name: data["labelData"]["name"],
            type: data["labelData"]["deviceType"],
            maker: data["maker"],
            model: data["model"]
          )
        end
      end
    end

    def status
      @status || fetch_status!
    end

    def fetch_status!
      client.control_device(device: self)

      @status = client.device_status(device: self)
    end

    # rubocop:disable Naming/AccessorMethodName
    def set_power_on!(value)
      send_payload!(:power_on, value)
    end

    def set_humidifier_on!(value)
      send_payload!(:humidifier_on, value)
    end

    def set_air_volume!(value)
      send_payload!(:air_volume, value)
    end
    # rubocop:enable Naming/AccessorMethodName

    protected

    def send_payload!(type, value)
      valid_values = Cocoro::PAYLOADS[type].keys
      unless valid_values.include?(value)
        raise Cocoro::Error, "Invalid #{type} value: #{value}. Valid values: #{valid_values}"
      end

      payload = Cocoro::PAYLOADS[type][value]
      client.control_device(device: self, changes: payload)
    end
  end
end
