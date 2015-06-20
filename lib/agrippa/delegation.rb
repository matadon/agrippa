require "agrippa/methods"

module Agrippa
    module Delegation
        def self.included(base)
            base.send(:include, Agrippa::Methods)
            base.send(:extend, ClassMethods)
        end

        def self.interpolate(string, vars)
            output = string.gsub(/[A-Z]{3,}/) do |match|
                vars.fetch(match.downcase.to_sym)
            end
            output.lines.map(&:strip).join("; ")
        end

        def self.build(base, delegate_caller, methods, definition)
            options = methods.last.is_a?(Hash) ? methods.pop.dup : {}
            target = options.delete(:to)
            target = "self.class" if (target.to_sym == :class)
            raise(ArgumentError) unless target

            options[:prefix] = target if (options[:prefix] == true)
            options[:suffix] = target if (options[:suffix] == true)

            file, line = delegate_caller.first.split(':', 2)
            line = line.to_i

            methods.each do |method|
                name = ::Agrippa::Methods.name(method, options)
                generated = ::Agrippa::Delegation.interpolate(definition,
                    name: name, target: target, method: method)
                base.send(:module_eval, generated, file, line)
            end
            self
        end

        module ClassMethods
            def delegate(*methods)
                ::Agrippa::Delegation.build(self, caller, methods, <<-END)
                    def NAME(*args, &block)
                        TARGET.METHOD(*args, &block)
                    end
                END
                self
            end

            def class_delegate(*methods)
                ::Agrippa::Delegation.build(self, caller, methods, <<-END)
                    def self.NAME(*args, &block)
                        TARGET.METHOD(*args, &block)
                    end
                END
                self
            end

            def delegate_command(*methods)
                ::Agrippa::Delegation.build(self, caller, methods, <<-END)
                    def NAME(*args, &block)
                        store('TARGET', TARGET.METHOD(*args, &block))
                    end
                END
                self
            end
        end
    end
end
