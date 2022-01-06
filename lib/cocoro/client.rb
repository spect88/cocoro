# frozen_string_literal: true

require "cgi"
require "logger"
require "faraday"
require "faraday_middleware"
require "faraday-cookie_jar"

require_relative "device"
require_relative "error"

module Cocoro
  # A client for the Cocoro Air API that the official mobile apps use.
  class Client
    BASE_URL = "https://hms.cloudlabs.sharp.co.jp/hems/pfApi/ta"
    BASE_HEADERS = {
      "Content-Type": "application/json; charset=utf-8",
      Accept: "*/*",
      "Accept-Language" => "ja-jp",
      "User-Agent" => <<~UA.gsub(/[\r\n ]+/, " ")
        smartlink_v200i Mozilla/5.0
        (iPhone; CPU iPhone OS 14_4 like Mac OS X)
        AppleWebKit/605.1.15 (KHTML, like Gecko)
        Mobile/15E148
      UA
    }.freeze
    DEFAULT_RESULT_CHECK_INTERVAL = 0.7 # seconds
    DEFAULT_RESULT_CHECK_MAX_ATTEMPTS = 20

    def initialize(app_secret:, terminal_app_id_key:, logger: nil)
      @app_secret = app_secret
      @terminal_app_id_key = terminal_app_id_key
      @logger = logger || Logger.new($stdout).tap do |l|
        l.level = Logger::WARN
      end
      @client = Faraday.new(
        url: BASE_URL,
        headers: BASE_HEADERS
      ) do |f|
        f.use :cookie_jar
        f.request :json
        f.response :logger, @logger, { bodies: true, log_level: :debug }
        f.response :raise_error
        f.response :json
        f.adapter :net_http
      end
    end

    def login
      body = {
        "terminalAppId" =>
          "https://db.cloudlabs.sharp.co.jp/clpf/key/#{@terminal_app_id_key}"
      }
      @client.post(
        "setting/login?appSecret=#{CGI.escape(@app_secret)}",
        body,
        {}
      )
    end

    def devices
      response = @client.get(
        "setting/boxInfo?appSecret=#{CGI.escape(@app_secret)}&mode=other"
      )
      json = response.body
      json["box"].flat_map do |box|
        box["echonetData"].map do |data|
          Cocoro::Device.new(
            client: self,
            box_id: box["boxId"],
            device_id: data["deviceId"],
            echonet_node: data["echonetNode"],
            echonet_object: data["echonetObject"],
            name: data["labelData"]["name"]
          )
        end
      end
    end

    def device_status(device:)
      query_params = {
        appSecret: @app_secret,
        boxId: device.box_id,
        echonetNode: device.echonet_node,
        echonetObject: device.echonet_object
      }.map { |k, v| [k, CGI.escape(v)].join("=") }
      response = @client.get(
        "control/deviceStatus?#{query_params.join("&")}"
      )
      json = response.body
      Cocoro::Status.new(json["deviceStatus"]["status"])
    end

    def control_device(
      device:,
      changes: [],
      result_check_interval: DEFAULT_RESULT_CHECK_INTERVAL,
      result_check_max_attempts: DEFAULT_RESULT_CHECK_MAX_ATTEMPTS
    )
      request_id = make_control_request!(device, changes)
      finished = false
      attempt = 0
      until finished
        attempt += 1
        result = fetch_control_result!(device, request_id)
        finished = result["status"] == "success" || result["status"] == "unmatch"
        next if finished
        raise Cocoro::Error, "Device not responding" if attempt >= result_check_max_attempts

        sleep result_check_interval
      end
    end

    protected

    def make_control_request!(device, changes)
      query_params = {
        appSecret: @app_secret,
        boxId: device.box_id
      }.map { |k, v| [k, CGI.escape(v)].join("=") }
      response = @client.post(
        "control/deviceControl?#{query_params.join("&")}",
        controlList: [
          {
            deviceId: device.device_id,
            echonetNode: device.echonet_node,
            echonetObject: device.echonet_object,
            status: changes
          }
        ]
      )
      response.body["controlList"].first["id"]
    end

    def fetch_control_result!(device, request_id)
      query_params = {
        appSecret: @app_secret,
        boxId: device.box_id
      }.map { |k, v| [k, CGI.escape(v)].join("=") }
      response = @client.post(
        "control/controlResult?#{query_params.join("&")}",
        resultList: [{ id: request_id }]
      )
      result = response.body["resultList"].first
      @logger.info("Status: #{result["status"]}")
      raise Cocoro::Error, "Error code: #{result["errorCode"]}" if result["status"] == "error"

      result
    end
  end
end
