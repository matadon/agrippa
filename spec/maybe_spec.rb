require "spec_helper"
require "agrippa/maybe"

RSpec.describe Agrippa::Maybe do
    it "handles nils" do
        instance = double(call: nil)
        expect(instance).to receive(:call)
        proxy = Agrippa::Maybe.new(instance)
        expect { proxy.call }.to_not raise_error
        expect { proxy.call }.to_not raise_error
        expect(proxy._value).to be_nil
    end

    it "handles unknown methods" do
        instance = Object.new
        proxy = Agrippa::Maybe.new(instance)
        expect { proxy.call }.to_not raise_error
        expect(proxy._value).to be_nil
    end

    it "chains" do
        finish = double(call: 42)
        start = double(call: finish)
        expect(start).to receive(:call)
        expect(finish).to receive(:call)
        proxy = Agrippa::Maybe.new(start)
        expect { proxy.call }.to_not raise_error
        expect(proxy._value).to eq(finish)
        expect { proxy.call }.to_not raise_error
        expect(proxy._value).to eq(42)
    end
end
