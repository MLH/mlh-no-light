# encoding: utf-8

require_relative "spec_helper"
require_relative "../no_light_sinatra.rb"

require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'capybara_minitest_spec'

Capybara.app = NoLightSinatra
Capybara.default_driver = :webkit


class MiniTest::Spec
  include Capybara::DSL
end

class Capybara::Session
  def params
    Hash[*URI.parse(current_url).query.split(/\?|=|&/)]
  end

  def find_classes(selector)
    find(selector)["class"].to_s.split(' ').map(&:to_sym)
  end
end