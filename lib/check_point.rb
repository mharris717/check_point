require 'mharris_ext'
require 'andand'
# require 'mongoid'
# require 'mongoid_gem_config'

module CheckPoint
  class << self
    def load!
      %w(main).each do |f|
        load File.dirname(__FILE__) + "/check_point/#{f}.rb"
      end
    end
    def root
      File.expand_path(File.dirname(__FILE__) + "/..")
    end
  end
end

# MongoidGemConfig.register_gems CheckPoint

CheckPoint.load!
