require "agrippa/methods"
require "agrippa/accessor_methods"

module Agrippa
    module MutableHash
        def self.included(base)
            base.send(:include, Agrippa::Methods)
            return if base.respond_to?(:state_reader)
            base.send(:extend, ClassMethods)
            base.send(:include, InstanceMethods)
            base.send(:mark_as_commands, :chain, :store)
            base.send(:private, :__apply_default_state)
        end

        module ClassMethods
            include AccessorMethods

            def __define_state_reader(key, original_caller, options)
                name = ::Agrippa::Methods.name(key, options)
                file, line = original_caller.first.split(':', 2)
                line = line.to_i
                spec = "def #{name}; @state[:#{key}]; end"
                module_eval(spec, file, line)
                self
            end

            def __define_state_writer(key, original_caller, options)
                name = ::Agrippa::Methods.name(key, options)
                name = ::Agrippa::Methods.name(name, prefix: "set") \
                    unless (options[:prefix] == false)
                file, line = original_caller.first.split(':', 2)
                line = line.to_i
                spec = "def #{name}(v); @state[:#{key}] = v; self; end"
                module_eval(spec, file, line)
                mark_as_command(name)
                self
            end
        end

        module InstanceMethods
            def initialize(state = nil)
                raise(ArgumentError, "#{self.class}#new requires a hash.") \
                    unless (state.nil? or state.respond_to?(:each_pair))
                __apply_default_state
                chain(state) if (state.respond_to?(:each_pair))
            end

            def chain(updates)
                raise(ArgumentError, "#set requires a Hash") \
                    unless updates.respond_to?(:each_pair)
                updates.each_pair { |key, value| store(key, value) }
                self
            end

            def store(key, value)
                @state.store(key.to_sym, value)
                self
            end

            def fetch(key, default = nil)
                @state.fetch(key.to_sym, default)
            end

            def __apply_default_state
                return(self) unless @state.nil?
                @state = default_state if respond_to?(:default_state)
                @state ||= {}
                self
            end
        end
    end
end
