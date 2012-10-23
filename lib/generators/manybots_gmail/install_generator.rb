require 'rails/generators'
require 'rails/generators/base'
require 'rails/generators/migration'


module ManybotsGmail
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      source_root File.expand_path("../../templates", __FILE__)
      
      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true
      class_option :migrations, :desc => "Generate migrations", :type => :boolean, :default => true
      
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      desc 'Mounts Manybots Gmail at "/manybots_gmail"'
      def add_manybots_gmail_routes
        route 'mount ManybotsGmail::Engine => "/manybots_gmail"' if options.routes?
      end
      
      desc "Copies ManybotsGmail migrations"
      def create_model_file
        migration_template "create_manybots_gmail_emails.rb", "db/migrate/create_manybots_gmail_emails.manybots_gmail.rb"
      end
      
      desc "Creates a ManybotsGmail initializer"
      def copy_initializer
        template "manybots_gmail.rb", "config/initializers/manybots_gmail.rb"
      end
      
      def show_readme
        readme "README" if behavior == :invoke
      end
      
    end
  end
end
