# -*- coding: utf-8 -*-
require 'find'
require 'fileutils'
require 'optparse'
require 'yaml'
require 'pathname'

require 'firefoxcache'
require 'polipocache'
require 'extensions/hash'


class CacheExtractor
  DEFAULT_CONF_PATH = Pathname.new(File.dirname(__FILE__) + '/../conf/conf.yaml')

  def initialize(argv)
    options = parse_opt(argv)
    conf_path = Pathname.new(options[:conf_path] || DEFAULT_CONF_PATH)
    raise ArgumentError, "設定ファイルが存在しません: #{conf_path}" unless conf_path.exist?

    confs = load_conf(options[:conf_path])
    @cache = create_cache_obj(confs)
  end

  def load_conf(path)
    YAML.load(path.read).symbolize_keys
  end

  def parse_opt(argv)
    opts = {}
    argv.options do |o|
      o.on("-c conf_path", "設定ファイルのパス") {|x| opts[:conf_path] = Pathname.new(x)}
      # o.on("-h", "--history", "現在のキャッシュヒストリを作成") {|x| opts[:history] = x}

      begin
        o.parse!
      rescue => err
        puts err.to_s
        exit
      end
    end
    {conf_path: DEFAULT_CONF_PATH}.merge(opts)
  end

  def extract
    @cache.extract
  end

  def create_cache_obj(options)
    case options[:cache_type]
    when "firefox"
      FirefoxCache.new(options)
    when "polipo"
      PolipoCache.new(options)
    else
      raise "キャッシュタイプが不正です: #{cache_type}"
    end
  end

  # def extract(num)
  #   # ファイルリスト作成
  #   file_list = []
  #   Find.find(@cache_dir) do |f|
  #     next unless File.file?(f)
  #     next if File.basename(f) =~ /_/
  #     file_list << f
  #   end

  #   # ファイルリストをサイズでソート
  #   sorted_file_list = file_list.sort_by do |item|
  #     -File::stat(item).size
  #   end

  #   # デバッグモード ON ならリストを表示して終了
  #   if DEBUG_MODE
  #     sorted_file_list.each do |f|
  #       puts "#{f} #{File::stat(f).size}"
  #     end
  #     return
  #   end

  #   # 大きいものからn個を抽出
  #   taken = sorted_file_list.take(num)

  #   # キャッシュから抽出
  #   puts "cache: #{@cache_dir}"
  #   puts "output: #{@extracted_dir}"
  #   puts "---"
  #   FileUtils.mkdir_p(@extracted_dir)
  #   taken.each do |f|
  #     output_path = @extracted_dir + '/' + File.basename(f) + EXTENSION
  #     cache_rpath = f.to_s[(@cache_dir.length+1)..-1]
  #     output_rpath = output_path[(@extracted_dir.length+1)..-1]
  #     puts "cache//#{cache_rpath} -> output//#{output_rpath} (#{File::stat(f).size})"
  #     if MOVE_MODE
  #       FileUtils.mv(f, output_path)
  #     else
  #       FileUtils.cp(f, output_path)
  #     end
  #   end
  # end
end
