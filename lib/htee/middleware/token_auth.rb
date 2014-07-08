module Htee
  module Middleware
    class TokenAuth < Struct.new(:app, :token)
      def call(env)
        header = env["HTTP_X_HTEE_AUTHORIZATION"].to_s
        token  = header[/Token (.*)$/, 1]

        if token == self.token
          self.app.call(env)
        else
          [401, {}, ['Unauthorized']]
        end
      end
    end
  end
end
