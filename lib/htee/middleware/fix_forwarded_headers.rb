module Htee
  module Middleware
    class FixForwardedHeaders < Struct.new(:app)
      def call(env)
        if proto = env['HTTP_X_HTEE_FORWARDED_PROTO']
          env['HTTP_X_FORWARDED_PROTO'] = proto
        end

        env.delete('HTTP_X_FORWARDED_PORT')

        self.app.call(env)
      end
    end
  end
end
