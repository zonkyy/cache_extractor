# -*- coding: utf-8 -*-
require 'pathname'
require 'tempfile'
require 'cache'

class PolipoCache < Cache
  def initialize(options)
    super

    @polipo_opts = {}
    if options[:website]
      @polipo_opts[:website] = options[:website].map do |item|
        Regexp.new(item)
      end
    else
      @polipo_opts[:website] = nil
    end
    @polipo_opts[:content_type] = options[:content_type]
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

  def match_site?(f, regexp_list)
    fpath = Pathname.new(f)
    cache_dir_name = fpath.dirname.basename.to_s
    regexp_list.any? {|re| re =~ cache_dir_name}
  end

  def match_content_type?(f, content_type)
    ftype = take_header(f, /Content-Type:/)
    content_type.any? {|t| ftype.include?(t)}
  end

  def delete_header(file)
    path = Pathname.new(file)
    offset = take_header(file, /X-Polipo-Body-Offset:/).to_i
    Tempfile.open("del_header_tmp") {|tmpf|
      tmpf.binmode
      File.open(path, "rb") {|f|
        f.read(offset)
        tmpf.write(f.read)
        FileUtils.cp(tmpf, f)
      }
    }
  end

  # 正規表現 marker に一致するヘッダ情報を取り出す
  def take_header(file, marker)
    str = ""
    File.open(file, "rb") { |f|
      f.lines.each do |line|
        if line =~ marker
          str = line.split(':')[1].strip
        end
      end
    }
    str
  end

  def cp(file, to)
    Tempfile.open("tmp") {|tmpf|
      FileUtils.cp(file, tmpf)
      tmpf.close
      delete_header(tmpf)
      super(tmpf, dest_path(file, to))
    }
  end

  def mv(file, to)
    dest = dest_path(file, to)
    delete_header(file)
    super(file, dest)
  end

  # 拡張子をつけたパスを返す
  def dest_path(file, to)
    fname = Pathname.new(file).basename.to_s + '.' + extension(file)
    to + fname
  end

  def extension(file)
    take_header(file, /Content-Type:/).split(/[\/-]/).last
  end
end
