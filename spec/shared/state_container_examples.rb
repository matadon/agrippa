RSpec.shared_examples_for "a state container" do
    let(:random_value) { Object.new }

    let(:instance) { klass.new }

    describe "#new" do
        it "empty" do
            expect { klass.new }.to_not raise_error
        end

        it "hash" do
            expect { klass.new(a: random_value, "b" => 2) }.to_not raise_error
        end

        it "otherwise explodes" do
            expect { klass.new(42) }.to raise_error(ArgumentError)
        end
    end

    describe ".state_reader" do
        it "returns a value" do
            klass.state_reader :a
            expect(instance).to respond_to(:a)
            expect(instance.a).to be(nil)
        end

        it "not command method" do
            klass.state_reader :a
            expect(klass.command_method?(:a)).to_not be(true)
        end

        it "prefix" do
            klass.state_reader :a, prefix: "foo"
            expect(instance).to respond_to(:foo_a)
        end

        it "suffix" do
            klass.state_reader :a, suffix: "foo"
            expect(instance).to respond_to(:a_foo)
        end
    end

    describe ".state_writer" do
        it "chainable" do
            klass.state_writer :a
            expect(instance).to respond_to(:set_a)
            expect(instance.set_a(:value)).to be_a(klass)
        end

        it "command method" do
            klass.state_writer :a
            expect(klass.command_method?(:set_a)).to be(true)
        end

        it "prefix" do
            klass.state_writer :a, prefix: "foo"
            expect(instance).to respond_to(:set_foo_a)
        end

        it "no prefix" do
            klass.state_writer :a, prefix: false
            expect(instance).to respond_to(:a)
        end

        it "suffix" do
            klass.state_writer :a, suffix: "foo"
            expect(instance).to respond_to(:set_a_foo)
        end
    end

    it ".state_accessor builds both" do
        klass.state_accessor :a
        expect(instance).to respond_to(:a)
        expect(instance).to respond_to(:set_a)
    end

    it "reader returns a value" do
        klass.state_accessor :a
        instance = klass.new(a: random_value)
        expect(instance.a).to be(random_value)
    end

    it "writer sets a value" do
        klass.state_accessor :a
        expect(instance.set_a(2).a).to eq(2)
    end

    it "#chain command method" do
        expect(klass.command_method?(:chain)).to be(true)
    end

    it "#chain sets multiple values" do
        klass.state_accessor :a, :b
        updated = instance.chain(a: random_value, b: 2)
        expect(updated).to be_a(klass)
        expect(updated.a).to be(random_value)
        expect(updated.b).to eq(2)
    end

    it "#store" do
        klass.state_accessor :a
        updated = instance.store(:a, random_value)
        expect(updated).to be_a(klass)
        expect(updated.a).to be(random_value)
    end

    it "#store indifferent on symbols and strings" do
        klass.state_accessor :a, :b
        expect(instance.store(:a, 1).a).to eq(1)
        expect(instance.store("b", 2).b).to eq(2)
    end

    it "#store command method" do
        expect(klass.command_method?(:store)).to be(true)
    end

    it "#fetch" do
        klass.state_accessor :a
        expect(instance.store(:a, random_value).fetch(:a)).to be(random_value)
    end

    it "#fetch default" do
        klass.state_accessor :a
        expect(instance.fetch(:a, random_value)).to be(random_value)
    end

    it "#fetch not command method" do
        expect(klass.command_method?(:fetch)).to be(false)
    end

    it "#fetch indifferent on symbols and strings" do
        updated = instance.store(:a, 1)
        expect(updated.fetch(:a)).to eq(1)
        expect(updated.fetch("a")).to eq(1)
    end

    it "#default_state" do
        klass.state_accessor :a
        klass.send(:define_method, :default_state) { { a: "default" } }
        expect(instance.a).to eq("default")
    end

    it "#default_state and new(state)" do
        klass.state_accessor :a, :b
        klass.send(:define_method, :default_state) { { a: 1 } }
        instance = klass.new(b: 2)
        expect(instance.a).to eq(1)
        expect(instance.b).to eq(2)
    end
end
