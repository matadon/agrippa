require "agrippa/proxy"

module Agrippa
    class State < Proxy
        def method_missing(method, *args, &block)
            output = @value.send(method, *args, &block)
            return(output) unless proxied_method?(method)
            @value = output
            self
        end
    end
end
