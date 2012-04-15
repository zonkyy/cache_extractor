# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/test_helper'
require 'cacheextractor'

describe_internally CacheExtractor, "は，" do
  before do
    ARGV.pop while ARGV.size > 0
    @extractor = CacheExtractor.new(ARGV)
  end

  describe "引数で" do
    before do
      ARGV.push '-c'
      ARGV.push './other_conf.yaml'
      @options = @extractor.parse_opt(ARGV)
    end
    it "設定ファイルのパスを読み込める" do
      path = Pathname.new('./other_conf.yaml')
      @options[:conf_path].should == path
    end
  end

  it "設定ファイルを正しく読み込める" do
    conf_path = Pathname.new(File.dirname(__FILE__) + '/test_conf.yaml')
    confs = @extractor.load_conf(conf_path)

    confs[:cache_type].should == "polipo"
    confs[:extract_mode].should == "copy"
    confs[:extension].should == "flv"
    confs[:max_extraction].should == 2
    confs[:cache_dir].should == "/home/akisute/program/cache_extractor/test/polipo_cache"
    confs[:extracted_dir].should == "/home/akisute/program/cache_extractor/test/extracted_cache"
    confs[:website].should have(3).items and
      confs[:website].should include '\.c.youtube\.com'
    confs[:content_type].should be_nil
    confs.should have(8).items
  end

  describe "キャッシュオブジェクト作成時に，" do
    it "Polipo用オブジェクトを作成できる" do
      conf_path = Pathname.new(File.dirname(__FILE__) + '/test_conf.yaml')
      opts = @extractor.load_conf(conf_path)
      opts[:cache_type] = 'polipo'
      @extractor.create_cache_obj(opts).should be_an_instance_of PolipoCache
    end

    it "Firefox用オブジェクトを作成できる" do
      conf_path = Pathname.new(File.dirname(__FILE__) + '/test_conf.yaml')
      opts = @extractor.load_conf(conf_path)
      opts[:cache_type] = 'firefox'
      @extractor.create_cache_obj(opts).should be_an_instance_of FirefoxCache
    end

    it "例外を発生できる" do
      conf_path = Pathname.new(File.dirname(__FILE__) + '/test_conf.yaml')
      opts = @extractor.load_conf(conf_path)
      opts[:cache_type] = 'chrome'
      proc{@extractor.create_cache_obj(opts)}.should raise_error
    end
  end
end
