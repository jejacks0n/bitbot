require "spec_helper"
require "rails/generators"
require_relative "../../lib/generators/bitbot/install/install_generator"

describe Bitbot::Generators::InstallGenerator do
  before do
    allow(subject).to receive(:copy_file)
  end

  describe "#copy_initializer" do
    it "installs the initializer file" do
      subject.copy_initializer
      expect(subject).to have_received(:copy_file).with(
        "templates/initializer.rb",
        "config/initializers/bitbot.rb"
      )
    end
  end

  describe "#display_post_install" do
    before do
      allow(subject).to receive(:readme)
    end

    it "displays the post install message if the behavior is to invoke" do
      expect(subject).to receive(:behavior).and_return(:invoke)

      subject.display_post_install
      expect(subject).to have_received(:readme).with("POST_INSTALL")
    end

    it "doesn't display a message if the behavior when the behavior is unknown" do
      expect(subject).to receive(:behavior).and_return(:unknown)

      subject.display_post_install
      expect(subject).to_not have_received(:readme).with("POST_INSTALL")
    end
  end

  context "the initializer" do
    before do
      allow(Bitbot).to receive(:configure).and_call_original
      allow(Rails).to receive(:root).and_return(Pathname.new(""))
    end

    it "configures Navigasmic" do
      load File.expand_path("../../../lib/generators/bitbot/install/templates/initializer.rb", __FILE__)
      expect(Bitbot).to have_received(:configure)
    end
  end
end
