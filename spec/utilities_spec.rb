require "spec_helper"
require "agrippa"

RSpec.describe Agrippa::Utilities do
    def try_require(*args)
        Agrippa::Utilities.try_require(*args)
    end

    it "#try_require success" do
        expect { try_require("securerandom") }.to_not raise_error
    end

    it "#try_require fail" do
        expect { try_require("totallynotagem") }.to_not raise_error
    end

    it "#try_require fail message" do
        expect { try_require("totallynotagem", "XXX") }
            .to raise_error(LoadError, /XXX/)
    end
end
