#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'cacheextractor'

cachex = CacheExtractor.new(ARGV)
cachex.extract
