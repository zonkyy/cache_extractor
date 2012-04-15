# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/test_helper'
require 'polipocache'
require 'extensions/hash'

require 'tmpdir'
require 'tempfile'

describe PolipoCache, "は，" do
  before do
    @options = {
      cache_type: "polipo",
      extract_mode: "copy",
      extension: "flv",
      max_extraction: 10,
      cache_dir: "./polipo_cache",
      extracted_dir: "./extracted_cache",
      website: ["youtube", "veoh", "niconico"],
      content_type: nil
    }
    @p_cache = PolipoCache.new(@options)
  end

  describe "ファイルリストを，" do
    before do
      # website と content_type を各テストで設定してから使用する
      @def_opts_for_filelist = {
        cache_type: "polipo",
        extract_mode: "copy",
        extension: "flv",
        max_extraction: 10,
        cache_dir: "./polipo_cache",
        extracted_dir: "./extracted_cache",
      }
    end

    it "全ファイルで作成できる" do
      @def_opts_for_filelist[:website] = nil
      @def_opts_for_filelist[:content_type] = nil
      cache = PolipoCache.new(@def_opts_for_filelist)
      flist = cache.file_list
      Find.find("./polipo_cache") do |f|
        next if not File.file?(f)
        flist.should include f
        flist.delete f
      end
      flist.should be_empty
    end

    it "指定したウェブサイトのみで作成できる" do
      @def_opts_for_filelist[:website] =
        [/\.c.youtube\.com/, /smile-pow\d{2}\.nicovideo\.jp/]
      @def_opts_for_filelist[:content_type] = nil
      cache = PolipoCache.new(@def_opts_for_filelist)
      flist = cache.file_list
      expected_flist =
        ["./polipo_cache/o-o.preferred.nrt19s13.v23.lscache6.c.youtube.com/Me9H40J8-N0aSmI8JnW1fQ==",
         "./polipo_cache/o-o.preferred.nrt19s13.v23.lscache6.c.youtube.com/LV1djCs+yiTT-OiWJC2NvA==",
         "./polipo_cache/smile-pow41.nicovideo.jp/62SpwxB386YAImT-RsbABQ==",
         "./polipo_cache/smile-pow41.nicovideo.jp/X7B4XHKywI96GPQn+PnwTg=="]
      flist.each do |f|
        expected_flist.delete(f).should_not be_nil
      end
      expected_flist.should be_empty
    end

    it "指定したファイルタイプのみで作成できる" do
      @def_opts_for_filelist[:website] = nil
      @def_opts_for_filelist[:content_type] = ["flv", "mp4"]
      cache = PolipoCache.new(@def_opts_for_filelist)
      flist = cache.file_list
      expected_flist =
        ["./polipo_cache/o-o.preferred.nrt19s13.v23.lscache6.c.youtube.com/Me9H40J8-N0aSmI8JnW1fQ==",
         "./polipo_cache/veoh-076.vo.llnwd.net/RCIAoy6NcOOTvIpV-JRu2Q==",
         "./polipo_cache/smile-pow41.nicovideo.jp/X7B4XHKywI96GPQn+PnwTg=="]
      flist.each do |f|
        expected_flist.delete(f).should_not be_nil
      end
      expected_flist.should be_empty
    end

    it "指定したウェブサイトかつファイルタイプで作成できる" do
      @def_opts_for_filelist[:website] = [/\.c.youtube\.com/]
      @def_opts_for_filelist[:content_type] = ["flv"]
      cache = PolipoCache.new(@def_opts_for_filelist)
      flist = cache.file_list
      expected_flist =
        ["./polipo_cache/o-o.preferred.nrt19s13.v23.lscache6.c.youtube.com/Me9H40J8-N0aSmI8JnW1fQ=="]
      flist.each do |f|
        expected_flist.delete(f).should_not be_nil
      end
      expected_flist.should be_empty
    end

    it "上限を越えずに作成できる" do
      @def_opts_for_filelist[:website] = nil
      @def_opts_for_filelist[:content_type] = nil
      @def_opts_for_filelist[:max_extraction] = 3
      cache = PolipoCache.new(@def_opts_for_filelist)
      flist = cache.file_list
      flist.size.should == 3
      expected_flist =
        ["./polipo_cache/o-o.preferred.nrt19s13.v23.lscache6.c.youtube.com/Me9H40J8-N0aSmI8JnW1fQ==",
         "./polipo_cache/veoh-076.vo.llnwd.net/RCIAoy6NcOOTvIpV-JRu2Q==",
         "./polipo_cache/smile-pow41.nicovideo.jp/X7B4XHKywI96GPQn+PnwTg=="]
      flist.each do |f|
        expected_flist.delete(f).should_not be_nil
      end
      expected_flist.should be_empty
    end
  end

  it "サイトを判断できる" do
    re_list = [/\.c.youtube\.com/, /smile-pow\d{2}\.nicovideo\.jp/]
    youtube_f = "./polipo_cache/o-o.preferred.nrt19s13.v23.lscache6.c.youtube.com/Me9H40J8-N0aSmI8JnW1fQ=="
    veoh_f = "./polipo_cache/veoh-076.vo.llnwd.net/RCIAoy6NcOOTvIpV-JRu2Q=="
    nico_f = "./polipo_cache/smile-pow41.nicovideo.jp/62SpwxB386YAImT-RsbABQ=="
    @p_cache.match_site?(youtube_f, re_list).should be_true
    @p_cache.match_site?(veoh_f, re_list).should be_false
    @p_cache.match_site?(nico_f, re_list).should be_true
  end

  describe "あるPolipoファイルに対して，" do
    before do
      @polipo_f = './polipo_cache/veoh-076.vo.llnwd.net/RCIAoy6NcOOTvIpV-JRu2Q=='
    end

    it "(対象となるPolipoファイルはヘッダが含まれたものであり)" do
      open(@polipo_f) {|f|
        f.gets.should match /^HTTP\/1.1 200 OK/
      }
    end

    it "Content-Type を取得できる" do
      @p_cache.match_content_type?(@polipo_f, ["video"]).should be_true
      @p_cache.match_content_type?(@polipo_f, ["flv"]).should be_true
      @p_cache.match_content_type?(@polipo_f, ["video/x-flv"]).should be_true
      @p_cache.match_content_type?(@polipo_f, ["mp4"]).should be_false
    end

    it "ヘッダが削除できる" do
      # バイナリの先頭2行のみ正しいファイルと比較して判定
      output = './extracted_cache/RCIAoy6NcOOTvIpV-JRu2Q=='
      Tempfile.open("tmp") {|tmpf|
        FileUtils.cp(@polipo_f, tmpf)
        tmpf.close
        @p_cache.delete_header(tmpf)
        tmpf.open
        open(output) {|f|
          tmpf.gets.should == f.gets
          tmpf.gets.should == f.gets
        }
      }
    end

    it "ヘッダ情報を取り出せる" do
      @p_cache.take_header(@polipo_f, /Content-Type:/).should == "video/x-flv"
      @p_cache.take_header(@polipo_f, /X-Polipo-Body-Offset:/).to_i.should == 8192
    end

    it "Polipoのキャッシュをコピーで抽出できる" do
      opts = @options.clone
      opts[:extract_mode] = "copy"
      @copy_p_cache = PolipoCache.new(opts)

      expected = './extracted_cache/RCIAoy6NcOOTvIpV-JRu2Q=='
      Dir.mktmpdir {|dir|
        to = Pathname.new(dir)
        @p_cache.cp(@polipo_f, to)
        flist = Dir.glob("#{dir}/*")
        flist.size.should == 1

        file = flist[0]
        open(expected) {|e|
          open(file) {|f|
            # バイナリの先頭2行のみ正しいファイルと比較して判定
            f.gets.should == e.gets
            f.gets.should == e.gets
          }
        }
      }

      # 元ファイルが残っていることを確認
      File.exist?(@polipo_f).should be_true
    end

    it "Polipoのキャッシュをムーブで抽出できる" do
      opts = @options.clone
      opts[:extract_mode] = "move"
      @copy_p_cache = PolipoCache.new(opts)

      expected = './extracted_cache/RCIAoy6NcOOTvIpV-JRu2Q=='

      # 先にムーブのテスト対象ファイルをコピー
      Dir.mktmpdir {|fromdir|
        frompath = Pathname.new(fromdir)
        FileUtils.cp(@polipo_f, frompath)
        fromlist = Dir.glob("#{fromdir}/*")
        fromlist.size.should == 1
        from = fromlist[0]

        # もう一つ tmpdir を作ってそこにムーブできるか確認
        Dir.mktmpdir {|dir|
          to = Pathname.new(dir)
          @p_cache.mv(from, to)

          # 移動元が消えていることを確認
          File.exist?(from).should be_false

          flist = Dir.glob("#{dir}/*")
          flist.size.should == 1

          file = flist[0]
          open(expected) {|e|
            open(file) {|f|
              # バイナリの先頭2行のみ正しいファイルと比較して判定
              f.gets.should == e.gets
              f.gets.should == e.gets
            }
          }
        }
      }
    end

    it "拡張子をつけたパスを取得できる" do
      filename = Pathname.new(@polipo_f).basename.to_s
      dest = @p_cache.dest_path(@polipo_f, "/tmp/")
      dest.should == "/tmp/#{filename}.flv"
    end
  end

  describe "拡張子の取得が" do
    before do
      @flv_f = './polipo_cache/veoh-076.vo.llnwd.net/RCIAoy6NcOOTvIpV-JRu2Q=='
    end

    it "flvファイルに対して行える" do
      @p_cache.extension(@flv_f).should == "flv"
    end
  end
end
