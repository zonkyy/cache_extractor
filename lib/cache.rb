# -*- coding: utf-8 -*-
require 'pathname'
require 'find'
require 'fileutils'

class Cache
  def initialize(options)
    @cache_path = Pathname.new(options[:cache_dir])
    @extracted_path = Pathname.new(options[:extracted_dir])
    @max_extraction = options[:max_extraction]
    @extract_mode = options[:extract_mode].to_sym
  end

  def extract()
    file_list.each do |f|
      puts "#{f} #{File::stat(f).size}"
      case @extract_mode
      when :copy
        cp(f, @extracted_path)
      when :move
        mv(f, @extracted_path)
      else
        raise "抽出モード(copy or move)が正しく設定されていません: #{@extract_mode}"
      end
    end
  end


  private
  def cp(f, to)
    FileUtils.cp(f, to)
  end

  def mv(f, to)
    FileUtils.mv(f, to)
  end
end
