# coding: utf-8
ENV['FREQ_ENV'] = "test"

require "bundler"
Bundler.require(:default, ENV['FREQ_ENV'] || 'test')