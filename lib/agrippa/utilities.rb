module Agrippa
    module Utilities
        def self.try_require(file, fail_message = nil)
            begin
                require(file)
            rescue LoadError => error
                return(false) if fail_message.nil?
                raise(LoadError, fail_message)
            end
        end
    end
end
