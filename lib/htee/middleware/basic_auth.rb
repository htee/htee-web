module Htee
  module Middleware
    class BasicAuth < Rack::Auth::Basic
      def call(env)

        if enabled? && browser?(env)
          super(env)
        else
          @app.call(env)
        end
      end

      def enabled?
        Htee.config.basic_user && Htee.config.basic_password
      rescue
        false
      end

      def browser?(env)
        env['HTTP_USER_AGENT'] =~ /WebKit|Gecko|Presto/
      end

      def valid?(auth)
        auth.username == Htee.config.basic_user &&
          auth.credentials.last == Htee.config.basic_password
      end
    end
  end
end
