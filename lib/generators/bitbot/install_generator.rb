module Bitbot
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path("../", __FILE__)

      desc 'Installs the Bitbot initializer into your Rails application.'

      def copy_initializer
        copy_file 'templates/initializer.rb', 'config/bitbot.rb'
      end

      def add_route
        route %{mount Bitbot.listener, at: 'rack-bitbot-webhook', via: :post}
      end

    end
  end
end
