require "spec_helper"
require "agrippa/delegation"
require "agrippa/mutable"
require "agrippa/immutable"

RSpec.describe Agrippa::Delegation do
    let(:klass) { Class.new.send(:include, Agrippa::Delegation) }

    let(:instance) { klass.new }

    describe ".delegate" do
        describe "to a method" do
            let(:receiver) { double(ping: "pong", bing: "bong") }

            before(:each) { klass.send(:attr_accessor, :target) }

            it "without a prefix" do
                expect(receiver).to receive(:ping)
                klass.delegate(:ping, to: :target)
                instance.target = receiver
                expect(instance.ping).to eq("pong")
            end

            it "with default prefix" do
                expect(receiver).to receive(:ping)
                klass.delegate(:ping, to: :target, prefix: true)
                instance.target = receiver
                expect(instance.target_ping).to eq("pong")
            end

            it "with custom prefix" do
                expect(receiver).to receive(:ping)
                klass.delegate(:ping, to: :target, prefix: "mister")
                instance.target = receiver
                expect(instance.mister_ping).to eq("pong")
            end

            it "with default suffix" do
                expect(receiver).to receive(:ping)
                klass.delegate(:ping, to: :target, suffix: true)
                instance.target = receiver
                expect(instance.ping_target).to eq("pong")
            end

            it "with custom suffix" do
                expect(receiver).to receive(:ping)
                klass.delegate(:ping, to: :target, suffix: "mister")
                instance.target = receiver
                expect(instance.ping_mister).to eq("pong")
            end

            it "accepts strings" do
                expect(receiver).to receive(:ping)
                klass.delegate("ping", to: :target)
                instance.target = receiver
                expect(instance.ping).to eq("pong")
            end

            it "multiple methods" do
                expect(receiver).to receive(:ping)
                klass.delegate(*%w(ping bing), to: :target)
                instance.target = receiver
                expect(instance.ping).to eq("pong")
                expect(instance.bing).to eq("bong")
            end

        end

        it "to the class" do
            klass.delegate(:ping, to: :class)
            receiver = Module.new
            receiver.send(:define_method, :ping) { "class pong" }
            klass.send(:extend, receiver)
            expect(instance.ping).to eq("class pong")
        end
    end

    describe ".class_delegate" do
        let(:receiver) { double(ping: "pong") }

        before(:each) do
            klass.class_eval("class << self; attr_accessor :target; end")
            klass.target = receiver
        end

        it "without a prefix" do
            expect(receiver).to receive(:ping)
            klass.class_delegate(:ping, to: :target)
            expect(klass.ping).to eq("pong")
        end

        it "with default prefix" do
            expect(receiver).to receive(:ping)
            klass.class_delegate(:ping, to: :target, prefix: true)
            expect(klass.target_ping).to eq("pong")
        end

        it "with custom prefix" do
            expect(receiver).to receive(:ping)
            klass.class_delegate(:ping, to: :target, prefix: "mister")
            expect(klass.mister_ping).to eq("pong")
        end

        it "with default suffix" do
            expect(receiver).to receive(:ping)
            klass.class_delegate(:ping, to: :target, suffix: true)
            expect(klass.ping_target).to eq("pong")
        end

        it "with custom suffix" do
            expect(receiver).to receive(:ping)
            klass.class_delegate(:ping, to: :target, suffix: "mister")
            expect(klass.ping_mister).to eq("pong")
        end
    end

    describe ".delegate_command" do
        let(:klass) do
            result = Class.new.send(:include, Agrippa::Delegation)
                .send(:include, Agrippa::Mutable)
                .state_accessor(:target)
        end

        let(:instance) { klass.new }

        let(:receiver_class) do
            Class.new.send(:include, Agrippa::Immutable)
                .state_accessor(:value)
        end

        let(:receiver) { receiver_class.new }

        let(:random_value) { Object.new }

        it "delegates" do
            klass.delegate_command(:set_value, to: :target)
            instance.set_target(receiver)
            expect(instance.target).to be(receiver)
            result = instance.set_value(random_value)
            expect(result).to be(instance)
            expect(instance.target).to be_a(receiver_class)
            expect(instance.target).to_not be(receiver)
            expect(instance.target.value).to be(random_value)
        end
    end
end
