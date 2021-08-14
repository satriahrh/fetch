# frozen_string_literal: true

require 'pry'
Dir['./lib/helpers/*'].each { |file| require file }
require_relative 'errors'
Dir['./lib/models/*'].each { |file| require file }
require_relative 'services'
