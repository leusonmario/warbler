#--
# Copyright (c) 2010-2012 Engine Yard, Inc.
# Copyright (c) 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

module Warbler
  module Traits
    # The JBundler trait uses JBundler to determine jar dependencies to
    # be added to the project.
    class JBundler
      include Trait
      include PathmapHelper

      def self.detect?
        File.exist?(ENV['JBUNDLE_JARFILE'] || "Jarfile")
      end

      def self.requires?(trait)
        trait == Traits::War || trait == Traits::Jar
      end

      def before_configure
        config.jbundler = true
      end

      def after_configure
        add_jbundler_jars if config.jbundler
      end

      def add_jbundler_jars
        begin
          require 'jbundler'
        rescue LoadError
          classpath = File.join( '.jbundler', 'classpath.rb' )
          if File.exists?( classpath )
            require File.expand_path( classpath )
          else
            raise 'jbundler support needs jruby to create a local config: jruby -S jbundle install'
          end
        end
        # use only the jars from jbundler
        config.java_libs.clear
        JBUNDLER_CLASSPATH.each do |jar|
          config.java_libs << jar
        end
        config.init_contents << "#{config.warbler_templates}/jbundler.erb"
      end
    end
  end
end
