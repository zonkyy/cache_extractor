# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/test_helper'
require 'firefoxcache'

describe_internally FirefoxCache, "は、" do
  before do
    @options = {
      cache_type: "polipo",
      extract_mode: "copy",
      extension: "flv",
      max_extraction: 10,
      cache_dir: "./firefox_cache",
      extracted_dir: "./extracted_cache",
    }
    @f_cache = FirefoxCache.new(@options)
  end

  it "ファイルリストを作成できる" do
    flist = @f_cache.file_list
    expected_flist =
      ['./firefox_cache/8/0A/D5E0Fd01', './firefox_cache/8/7B/240B3d01',
       './firefox_cache/1/1B/6FB20d01', './firefox_cache/1/1A/18A9Ed01',
       './firefox_cache/F/AB/E3B88d01', './firefox_cache/E/20/25FD5d01',
       './firefox_cache/6/E2/26677d01', './firefox_cache/1/5B/02574d01',
       './firefox_cache/A/B4/00452d01', './firefox_cache/0/1C/BF030d01']
    flist.size.should == 10
    flist.each do |f|
      expected_flist.delete(f).should_not be_nil
    end
    expected_flist.should be_empty
  end
end
