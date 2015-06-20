require "spec_helper"
require "agrippa/state"

RSpec.describe Agrippa::State do
    it "command methods update" do
        value = double(ping: "pong", :command_method? => true)
        proxy = Agrippa::State.new(value)
        expect(proxy.ping.__id__).to eq(proxy.__id__)
        expect(proxy._value).to eq("pong")
    end

    it "query methods return" do
        value = double(ping: "pong", :command_method? => false)
        proxy = Agrippa::State.new(value, :ping)
        expect(proxy.ping).to eq("pong")
    end
end
