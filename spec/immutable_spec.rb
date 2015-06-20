require "spec_helper"
require "shared/state_container_examples"
require "agrippa/immutable"

RSpec.describe Agrippa::Immutable do
    let(:klass) { Class.new.send(:include, Agrippa::Immutable) }

    it_behaves_like "a state container"

    it "#store does not mutate" do
        instance = klass.new(a: 1)
        expect(instance.store(:b, 2)).to_not be(instance)
    end

    describe "#new" do
        it "directly uses Hamster::Hash" do
            initial_state = Hamster::Hash.new(a: 1)
            instance = klass.new(initial_state)
            final_state = instance.instance_variable_get(:@state)
            expect(final_state).to be(initial_state)
        end
    end
end
