require "agrippa/utilities"
require "agrippa/methods"
require "agrippa/accessor_methods"

Agrippa::Utilities.try_require("hamster/hash",
    "Agrippa::Immutable requires the Hamster gem.")

module Agrippa
    module Immutable
        def self.included(base)
            base.send(:include, Agrippa::Methods)
            return if base.respond_to?(:state_reader)
            base.send(:extend, ClassMethods)
            base.send(:include, InstanceMethods)
            base.send(:mark_as_commands, :chain, :store)
            base.send(:private, :__symbolize_keys)
        end

        module ClassMethods
            include AccessorMethods

            def __define_state_reader(key, original_caller, options)
                name = ::Agrippa::Methods.name(key, options)
                file, line = original_caller.first.split(':', 2)
                line = line.to_i
                spec = "def #{name}; fetch(:#{key}); end"
                module_eval(spec, file, line)
                self
            end

            def __define_state_writer(key, original_caller, options)
                name = ::Agrippa::Methods.name(key, options)
                name = ::Agrippa::Methods.name(name, prefix: "set") \
                    unless (options[:prefix] == false)
                file, line = original_caller.first.split(':', 2)
                line = line.to_i
                spec = "def #{name}(v); store(:#{key}, v); end"
                module_eval(spec, file, line)
                mark_as_command(name)
                self
            end
        end

        module InstanceMethods
            def initialize(state = Hamster::Hash.new, apply_default = true)
                raise(ArgumentError, "#{self.class}#new requires a hash.") \
                    unless state.respond_to?(:each_pair)
                if(apply_default and respond_to?(:default_state))
                    @state = Hamster::Hash.new(default_state)
                    @state = @state.merge(state) unless state.nil?
                elsif(state.is_a?(Hamster::Hash))
                    @state = state
                else
                    @state = Hamster::Hash.new(__symbolize_keys(state))
                end
            end

            def chain(updates)
                raise(ArgementError, "#set requires a Hash") \
                    unless updates.respond_to?(:each_pair)
                self.class.new(@state.merge(__symbolize_keys(updates)), false)
            end

            def store(key, value)
                self.class.new(@state.store(key.to_sym, value), false)
            end

            def fetch(key, default = nil)
                @state.fetch(key.to_sym, default)
            end

            def __symbolize_keys(input)
                output = input.dup
                input.keys { |k| output[k.to_sym] = output.delete(k) \
                    unless k.is_a?(Symbol) }
                output
            end
        end
    end
end
