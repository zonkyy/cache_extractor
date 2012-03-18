#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'find'
require 'fileutils'
require 'optparse'


######### ユーザ設定 ここから #########
### パス関係(引数での指定がなければ，以下の定数が使用される)
# キャッシュが置かれている絶対パス．ホームディレクトリは ~ でなく ENV["HOME"]．区切りは / を使用すること．
# win例: 'C:/User/user-name/AppData/Roaming/Mozilla/Firefox/Profiles/1234567.default/Cache'
# ubuntu例: 'ENV["HOME"]' + '/.mozilla/firefox/1234567.default/Cache'
CACHE_PATH = ENV["HOME"] + '/.mozilla/firefox/ijq290rk.default/Cache'
# 抽出先のパス
EXTRACTED_PATH = ENV["HOME"] + '/Downloads/ExtractedCache'

### オプション('true' or 'false')
# デバッグモードを ON にするなら true
# (移動は行わず，キャッシュパス内のファイルをサイズでソートして表示．
# CACHE_PATHの書き方が正しいかの確認にでも．)
DEBUG_MODE = false
# 抽出したファイルをキャッシュから削除するなら true
MOVE_MODE = true
######### ここまで #########


class CacheExtractor
  def initialize(cache_dir, extracted_dir)
    @cache_dir = (cache_dir or CACHE_PATH)
    @extracted_dir = (extracted_dir or EXTRACTED_PATH)
  end

  def extract(num)
    # ファイルリスト作成
    file_list = []
    Find.find(@cache_dir) do |f|
      next unless File.file?(f)
      next if File.basename(f).to_s[0] == '_'
      file_list << f
    end

    # ファイルリストをサイズでソート
    sorted_file_list = file_list.sort_by do |item|
      -File::stat(item).size
    end

    # デバッグモード ON ならリストを表示して終了
    if DEBUG_MODE
      sorted_file_list.each do |f|
        puts "#{f} #{File::stat(f).size}"
      end
      return
    end

    # 大きいものからn個を抽出
    taken = sorted_file_list.take(num)

    # キャッシュから抽出
    STDOUT.puts "output: #{@extracted_dir}"
    FileUtils.mkdir_p(@extracted_dir)
    taken.each do |f|
      puts "#{f} #{File::stat(f).size}"
      if MOVE_MODE
        FileUtils.mv(f, @extracted_dir)
      else
        FileUtils.cp(f, @extracted_dir)
      end
    end
  end
end



if __FILE__ == $0
  opts = {}
  ARGV.options do |o|

    o.banner = <<"EOS"
SYNOPSIS
#{o.summary_indent}ruby #$0 --help
#{o.summary_indent}ruby #$0 [(-e|--extension) extension]
#{o.summary_indent}     #{opt_indent = ' '*($0.size+1)}[(-d|--dir) cacheDir]
#{o.summary_indent}     #{opt_indent}[(-o|--os) OS]
#{o.summary_indent}     #{opt_indent}(-h | num)
EOS
    o.separator ""
    o.separator "OPTIONS"
    # o.on("-h", "--history", "現在のキャッシュヒストリを作成") {|x| opts[:history] = x}
    o.on("-e extension", "--extension", "取得時にファイル名に付与する拡張子") {|x| opts[:extension] = x}
    o.on("-f cacheDir", "--from", "キャッシュディレクトリ(絶対パス)") {|x| opts[:cache_dir] = x}
    o.on("-t extractedDir", "--to", "移動先ディレクトリ(絶対パス)") {|x| opts[:extracted_dir] = x}
    # o.on("-o OS", "--os", SUPPORTED_OS_REGEXP,"使用OS(-d優先)") {|x| opts[:os] = x}
    # o.on("-m", "--move", "キャッシュディレクトリから抽出したファイルを削除") {|x| opts[:move] = x}
    # o.on("確認無しに強制コピーor移動")

    begin
      o.parse!
    rescue => err
      puts err.to_s
      exit
    end
  end

  # キャッシュパスを決定したGetCacheオブジェクト作成
  extracter = CacheExtractor.new(opts[:cache_dir], opts[:extracted_dir])

  if opts[:history]
    # todo
  else
    extracter.extract(ARGV[0].to_i)
  end
end
