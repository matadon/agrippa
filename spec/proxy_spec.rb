require "spec_helper"
require "agrippa/proxy"
require "agrippa/methods"

RSpec.describe Agrippa::Proxy do
    let(:klass) { Class.new }

    let(:instance) { klass.new }
    
    it "requires subclasses to implement method_missing" do
        proxy = Agrippa::Proxy.new(instance)
        expect { proxy.foo }.to raise_error(NoMethodError)
    end

    describe "proxied methods" do
        it "everything by default" do
            proxy = Agrippa::Proxy.new(instance)
            expect(proxy.proxied_method?(:foo)).to be(true)
        end

        it "specified only" do
            proxy = Agrippa::Proxy.new(instance, :a, "b")
            expect(proxy.proxied_methods).to eq(a: true, b: true)
            expect(proxy.proxied_method?(:c)).to be(false)
        end

        it "command" do
            klass.send(:include, Agrippa::Methods)
            klass.mark_as_command(:a)
            proxy = Agrippa::Proxy.new(instance)
            expect(proxy.proxied_methods).to eq(a: true)
        end

        it "both specified and command" do
            klass.send(:include, Agrippa::Methods)
            klass.mark_as_command(:a)
            proxy = Agrippa::Proxy.new(instance, :b)
            expect(proxy.proxied_methods).to eq(a: true, b: true)
        end
    end

    it "#is_a? wrapped class" do
        proxy = Agrippa::Proxy.new(instance)
        expect(proxy.is_a?(klass)).to be(true)
    end

    it "#is_a? proxy" do
        proxy = Agrippa::Proxy.new(instance)
        expect(proxy.is_a?(Agrippa::Proxy)).to be(true)
    end

    it "#respond_to? proxy" do
        proxy = Agrippa::Proxy.new(instance)
        expect(proxy.respond_to?(:proxied_methods)).to be(true)
        expect(proxy.respond_to?(:total_bullshit)).to be(false)
    end

    it "#respond_to? wrapped" do
        instance = double(ping: "pong")
        proxy = Agrippa::Proxy.new(instance)
        expect(proxy.respond_to?(:ping)).to be(true)
        expect(proxy.respond_to?(:pong)).to be(false)
    end

    it "#_value" do
        inner_class = Class.new(Agrippa::Proxy)
        outer_class = Class.new(Agrippa::Proxy)
        instance = double()
        inner = inner_class.new(instance)
        outer = outer_class.new(inner)
        expect(outer._value.__id__).to eq(inner.__id__)
    end

    it "#_ returns #_value" do
        inner_class = Class.new(Agrippa::Proxy)
        outer_class = Class.new(Agrippa::Proxy)
        instance = double()
        inner = inner_class.new(instance)
        outer = outer_class.new(inner)
        expect(outer._.__id__).to eq(outer._value.__id__)
    end

    it "#_deep_value" do
        inner_class = Class.new(Agrippa::Proxy)
        outer_class = Class.new(Agrippa::Proxy)
        instance = double()
        inner = inner_class.new(instance)
        outer = outer_class.new(inner)
        expect(outer._deep_value).to be(instance)
    end

    it "proxies" do
        passthrough = Module.new do
            def method_missing(name, *args, &block)
                @value.send(name, *args, &block)
            end
        end
        inner_class = Class.new(Agrippa::Proxy)
            .send(:include, passthrough)
        outer_class = Class.new(Agrippa::Proxy)
            .send(:include, passthrough)
        instance = double(ping: "pong")
        inner = inner_class.new(instance)
        outer = outer_class.new(inner)
        expect(outer.ping).to eq("pong")
    end
end
