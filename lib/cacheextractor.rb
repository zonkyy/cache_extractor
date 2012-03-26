# -*- coding: utf-8 -*-
require 'find'
require 'fileutils'


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
MOVE_MODE = false

### その他
# 抽出ファイルの拡張子(ピリオドから記述．指定しない場合は'')
EXTENSION = '.flv'
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
      next if File.basename(f) =~ /_/
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
    puts "cache: #{@cache_dir}"
    puts "output: #{@extracted_dir}"
    puts "---"
    FileUtils.mkdir_p(@extracted_dir)
    taken.each do |f|
      output_path = @extracted_dir + '/' + File.basename(f) + EXTENSION
      cache_rpath = f.to_s[(@cache_dir.length+1)..-1]
      output_rpath = output_path[(@extracted_dir.length+1)..-1]
      puts "cache//#{cache_rpath} -> output//#{output_rpath} (#{File::stat(f).size})"
      if MOVE_MODE
        FileUtils.mv(f, output_path)
      else
        FileUtils.cp(f, output_path)
      end
    end
  end
end
