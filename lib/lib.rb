# frozen_string_literal: true

require 'pry'
require 'concurrent'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'json'
require 'base64'

Dir['./lib/helpers/*'].each { |file| require file }
require_relative 'errors'
Dir['./lib/models/*'].each { |file| require file }
require_relative 'services'
