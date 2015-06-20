require "agrippa/methods"

module Agrippa
    class Proxy < BasicObject
        include Methods

        instance_methods.each do |method|
            next if (method =~ /(^__|^nil\?$|^send$|^object_id$)/)
            undef_method(method) 
        end

        attr_reader :proxied_methods

        def initialize(value, *methods)
            @value, @proxied_methods = value, {}
            __build_method_lookup_table(value, methods.flatten)
        end

        def _value
            @value
        end

        def _
            @value
        end

        def _deep_value
            return(@value) unless @value.respond_to?(:_value)
            @value._value
        end

        def respond_to?(method, include_private = false)
            return(true) if (method == :_value)
            return(true) if (method == :proxied_methods)
            return(true) if (method == :proxied_method?)
            @value.respond_to?(method, include_private)
        end

        def is_a?(klass)
            @value.is_a?(klass) || (klass == ::Agrippa::Proxy)
        end

        def proxied_method?(method)
            @proxied_methods.empty? \
                or @proxied_methods.has_key?(method.to_sym)
        end

        def method_missing(method, *args, &block)
            ::Kernel.raise(::NoMethodError,
                "Implement method_missing in a subclass.")
        end

        def __set_proxied_methods(lookup_hash)
            @proxied_methods = lookup_hash
            self
        end

        private

        def __class
            @__class ||= (class << self; self end).superclass
        end

        def __chain(value)
            __class.new(value, false).__set_proxied_methods(@proxied_methods)
        end

        def __build_method_lookup_table(value, methods)
            return(self) if (methods.first == false)
            @proxied_methods.merge!(value.command_methods) \
                if value.respond_to?(:command_methods)
            methods.each { |method| @proxied_methods[method.to_sym] = true }
            self
        end
    end
end

