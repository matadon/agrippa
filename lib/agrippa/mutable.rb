require "agrippa/methods"
require "agrippa/accessor_methods"

module Agrippa
    module Mutable
        def self.included(base)
            base.send(:include, Agrippa::Methods)
            return if base.respond_to?(:state_reader)
            base.send(:extend, ClassMethods)
            base.send(:include, InstanceMethods)
            base.send(:mark_as_commands, :chain, :store)
        end

        module ClassMethods
            include AccessorMethods

            def __define_state_reader(key, original_caller, options)
                name = ::Agrippa::Methods.name(key, options)
                file, line = original_caller.first.split(':', 2)
                line = line.to_i
                spec = "def #{name}; @#{key}; end"
                module_eval(spec, file, line)
                self
            end

            def __define_state_writer(key, original_caller, options)
                name = ::Agrippa::Methods.name(key, options)
                name = ::Agrippa::Methods.name(name, prefix: "set") \
                    unless (options[:prefix] == false)
                file, line = original_caller.first.split(':', 2)
                line = line.to_i
                spec = "def #{name}(value); @#{key} = value; self; end"
                module_eval(spec, file, line)
                mark_as_command(name)
                self
            end
        end

        module InstanceMethods
            def initialize(state = nil)
                chain(default_state) if respond_to?(:default_state)
                chain(state) unless state.nil?
            end

            def chain(state)
                raise(ArgumentError, "#set requires a Hash") \
                    unless state.respond_to?(:each_pair)
                state.each_pair { |key, value| store(key, value) }
                self
            end

            def store(key, value)
                instance_variable_set("@#{key}", value)
                self
            end

            def fetch(key, default = nil)
                instance_variable_get("@#{key}") || default
            end
        end
    end
end
