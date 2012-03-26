#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'optparse'

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
