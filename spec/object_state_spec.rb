require "spec_helper"
require "agrippa/mutable"
require "agrippa/mutable_hash"
require "agrippa/immutable"
require "shared/state_container_examples"

RSpec.describe Agrippa::Mutable do
    let(:klass) { Class.new.send(:include, Agrippa::Mutable) }

    it_behaves_like "a state container"

    it "#store mutates" do
        instance = klass.new(a: 1)
        expect(instance.store(:b, 2)).to be(instance)
    end
end

RSpec.describe Agrippa::MutableHash do
    let(:klass) { Class.new.send(:include, Agrippa::MutableHash) }

    it_behaves_like "a state container"

    it "#store mutates" do
        instance = klass.new(a: 1)
        expect(instance.store(:b, 2)).to be(instance)
    end
end

RSpec.describe Agrippa::Immutable do
    let(:klass) { Class.new.send(:include, Agrippa::Immutable) }

    it_behaves_like "a state container"

    it "#store does not mutate" do
        instance = klass.new(a: 1)
        expect(instance.store(:b, 2)).to_not be(instance)
    end
end
