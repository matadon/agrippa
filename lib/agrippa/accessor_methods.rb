module Agrippa
    module AccessorMethods
        def state_reader(*args)
            options = args.last.is_a?(Hash) ? args.pop : {}
            args.flatten.each do |arg|
                __define_state_reader(arg, caller, options)
            end
            self
        end

        def state_writer(*args)
            options = args.last.is_a?(Hash) ? args.pop : {}
            args.flatten.each do |arg|
                __define_state_writer(arg, caller, options)
            end
            self
        end

        def state_accessor(*args)
            options = args.last.is_a?(Hash) ? args.pop : {}
            args.flatten.each do |arg|
                __define_state_reader(arg, caller, options)
                __define_state_writer(arg, caller, options)
            end
            self
        end
    end
end
