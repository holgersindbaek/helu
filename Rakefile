# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")

require 'motion/project/template/ios'

# Require bundler
require 'bundler'
require "bundler/gem_tasks"
require "bundler/setup"
Bundler.require :default

require 'sugarcube'
require 'sugarcube-568'
require 'sugarcube-attributedstring'
require 'sugarcube-anonymous'
require 'sugarcube-gestures'
require 'bubble-wrap/core'
require 'bubble-wrap/reactor'

require './lib/helu'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'helu'
  app.frameworks << "StoreKit"
end
