# -*- coding: utf-8 -*-
require 'pathname'
require 'find'
require 'fileutils'

# あるキャッシュディレクトリ内のファイルリスト
class Cache
  def initialize(options)
    @cache_path = Pathname.new(options[:cache_dir])
    @extracted_path = Pathname.new(options[:extracted_dir])
    @max_extraction = options[:max_extraction]
    @polipo_opts = {}
  end

  def file_list
    flist = []
    Find.find(@cache_path) do |f|
      next unless File.file?(f)
      if @polipo_opts[:website]
        next unless match_site?(f, @polipo_opts[:website])
      end
      if @polipo_opts[:content_type]
        next unless match_content_type?(f, @polipo_opts[:content_type])
      end
      flist << f
    end

    flist = flist.sort_by do |item|
      -File::stat(item).size
    end

    flist = flist[0...@max_extraction] if @max_extraction > 0
    flist
  end

  def extract(mode = :copy)
    file_list.each do |f|
      puts "#{f} #{File::stat(f).size}"
      if mode == :copy
        cp(f, @extracted_path)
      else
        mv(f, @extracted_path)
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