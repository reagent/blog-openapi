class AuthHeader
  class InvalidCredentialTypeError < StandardError
    def initialize
      super('Unrecognized authorization credentials, allowed values are `Basic` or `Bearer`')
    end
  end

  def initialize(value, credentials)
    @value = value
    @credentials = credentials
  end

  def authenticated?
    return false unless @value.present?

    pattern = /^(?<type>Basic|Bearer)\s+(?<value>(.+))$/
    matches = @value.match(pattern)

    raise InvalidCredentialTypeError unless matches

    type, value = matches.named_captures.values_at('type', 'value')

    if type == 'Bearer'
      authenticate_as_bearer_token(value)
    else
      authenticate_as_basic(value)
    end
  end

  private

  def authenticate_as_basic(value)
    username, password = Base64.strict_decode64(value).split(':')
    username == @credentials.basic.username && password == @credentials.basic.password
  end

  def authenticate_as_bearer_token(value)
    value == @credentials.bearer.token
  end
end
