require "spec_helper"
require "shared/state_container_examples"
require "agrippa/mutable"

RSpec.describe Agrippa::Mutable do
    let(:klass) { Class.new.send(:include, Agrippa::Mutable) }

    it_behaves_like "a state container"

    it "#store mutates" do
        instance = klass.new(a: 1)
        expect(instance.store(:b, 2)).to be(instance)
    end
end
