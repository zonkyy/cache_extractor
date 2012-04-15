require 'pathname'
require 'find'
require 'cache'

class FirefoxCache < Cache
  def file_list
    flist = []
    Find.find(@cache_path) do |f|
      next unless File.file?(f)
      next if f =~ /_CACHE_00\d_/
      flist << f
    end

    flist = flist.sort_by do |item|
      -File::stat(item).size
    end

    flist = flist[0...@max_extraction] if @max_extraction > 0
    flist
  end
end

