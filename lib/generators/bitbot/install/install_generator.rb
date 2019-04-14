module Bitbot
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../", __FILE__)

      desc "Installs the Bitbot initializer into your application."

      def copy_initializer
        copy_file "templates/initializer.rb", "config/initializers/bitbot.rb"
      end

      def add_route
        route %{mount Bitbot.listener, at: 'rack-bitbot-webhook', via: :post}
      end

      def display_post_install
        readme "POST_INSTALL" if behavior == :invoke
      end
    end
  end
end
