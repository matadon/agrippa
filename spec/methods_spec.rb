require "spec_helper"
require "agrippa/methods"

RSpec.describe Agrippa::Methods do
    let(:klass) { Class.new.send(:include, Agrippa::Methods) }

    describe ".command_methods" do
        def methods
            klass.command_methods
        end

        it "empty by default" do
            expect(methods).to be_empty
        end

        describe "adds methods" do
            it "single string" do
                klass.mark_as_commands "foo"
                expect(methods).to eq(foo: true)
            end

            it "single symbol" do
                klass.mark_as_commands :foo
                expect(methods).to eq(foo: true)
            end
            
            it "list of symbols" do
                klass.mark_as_commands :foo, :bar
                expect(methods).to eq(foo: true, bar: true)
            end

            it "array of strings" do
                klass.mark_as_commands %w(foo bar)
                expect(methods).to eq(foo: true, bar: true)
            end
        end
    end
end
