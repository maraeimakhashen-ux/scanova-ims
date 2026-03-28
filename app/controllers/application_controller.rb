class ApplicationController < ActionController::API
  include ActionController::DataStreaming

  before_action :normalize_params

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def normalize_params
    request.parameters.deep_transform_keys! do |key|
      key.to_s.gsub(/([A-Z])/) { "_#{$1.downcase}" }
    end
  rescue TypeError, ArgumentError => e
    Rails.logger.warn("normalize_params failed: #{e.message}")
  end

  def not_found(e = nil)
    render json: { error: e&.message || "Not found" }, status: :not_found
  end

  def bad_request(e = nil)
    render json: { error: e&.message || "Bad request" }, status: :bad_request
  end
end
