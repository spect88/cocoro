# frozen_string_literal: true

module Cocoro
  # Base error class
  class Error < StandardError
  end

  # Any non-200 response from the API
  #
  # That includes 400 responses which seems to be happening
  # occasionally without any fault on the client side.
  class ServerError < Cocoro::Error
  end

  # 401 or 403 error
  class AuthError < Cocoro::ServerError
  end
end
