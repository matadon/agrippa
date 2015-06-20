require "agrippa/proxy"

module Agrippa
    class Maybe < Proxy
        def method_missing(method, *args, &block)
            return(self) if @value.nil?
            output = begin
                @value.send(method, *args, &block)
            rescue ::NoMethodError
                nil
            end
            return(output) unless proxied_method?(method)
            @value = output
            __chain(@value)
        end
    end        
end

