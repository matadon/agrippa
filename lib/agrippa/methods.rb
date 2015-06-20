module Agrippa
    class MethodRedefinitionError < StandardError
        def initialize(klass, method)
            @klass, @method = klass, method
        end

        def to_s
            "Redefinition of #{@klass}##{@method}; use the 'redefine' option if you really want to overwrite the existing method."
        end
    end

    module Methods
        def self.included(base)
            return if base.respond_to?(:command_methods)
            base.send(:extend, ClassMethods)
            base.send(:include, InstanceMethods)
        end

        def self.name(name, options = {})
            result = name
            suffix = options[:suffix]
            result = "#{result}_#{suffix}".to_sym if suffix
            prefix = options[:prefix]
            result = "#{prefix}_#{result}".to_sym if prefix
            result
        end

        module ClassMethods
            def mark_as_commands(*args)
                args.flatten.each do |arg|
                    command_methods[arg.to_sym] = true
                end
            end

            alias_method :mark_as_command, :mark_as_commands

            def command_methods
                @__command_methods ||= {}
            end

            def command_method?(name)
                command_methods.has_key?(name.to_sym)
            end
        end

        module InstanceMethods
            def command_methods
                self.class.command_methods
            end
        end
    end
end
