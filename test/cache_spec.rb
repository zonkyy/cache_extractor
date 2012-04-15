# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/test_helper'
require 'cache'

require 'tmpdir'
require 'tempfile'

describe_internally Cache, "は、" do
  before do
    options = {
      cache_dir: '/home/akisute/program/cache_extractor/test/polipo_cache',
      extracted_dir: '/home/akisute/program/cache_extractor/test/extracted_cache',
      max_extraction: 2,
      extract_mode: 'copy'
    }
    @cache = Cache.new(options)
  end

  describe "初期化設定で" do
    it "キャッシュのパスを正しく設定できる" do
      @cache.instance_variable_get(:@cache_path).should ==
        Pathname.new('/home/akisute/program/cache_extractor/test/polipo_cache')
    end

    it "抽出先を正しく設定できる" do
      @cache.instance_variable_get(:@extracted_path).should ==
        Pathname.new('/home/akisute/program/cache_extractor/test/extracted_cache')
    end

    it "最大抽出数を正しく設定できる" do
      @cache.instance_variable_get(:@max_extraction).should == 2
    end

    it "抽出モードを正しく設定できる" do
      @cache.instance_variable_get(:@extract_mode).should == :copy
    end
  end
end
