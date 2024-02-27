class ApplicationController < ActionController::API
  rescue_from AuthHeader::InvalidCredentialTypeError, with: :handle_invalid_credentials
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  private

  def handle_invalid_credentials
    render(
      json: { message: 'You are not authorized to perform this action' },
      status: :unauthorized
    )
  end

  def handle_record_invalid(exception)
    render(
      json: { message: exception.message },
      status: :unprocessable_entity
    )
  end

  def handle_record_not_found(exception)
    render(
      json: { message: "Couldn't find #{exception.model} with 'id'=#{exception.id}" },
      status: :not_found
    )
  end

  def authenticated?
    @is_authenticated ||= begin
      header = AuthHeader.new(
        request.headers['Authorization'],
        Rails.configuration.x.auth
      )

      header.authenticated?
    end
  end
end
