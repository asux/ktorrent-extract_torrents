require "thor"
require "bencodr"
require "fileutils"

class Ktorrent < Thor
  map "-L" => :list

  no_tasks do
    def ktorrent_dir(kde_dir)
      "#{kde_dir}/share/apps/ktorrent"
    end

    def file_list(kde_dir)
      Dir["#{ktorrent_dir(kde_dir)}/**/torrent"]
    end
  end

  desc  "ktorrent extract_torrents [DESTINATION_DIR]", "extract KTorrent files"
  method_option :kde_dir, :type => :string,
    :default => "~/.kde4", required: false,
    :desc => "KDE directory"
  def extract_torrents(destination_dir="~/extracted_torrents")
    destination_dir = destination_dir.gsub("~", ENV["HOME"])
    FileUtils.mkdir_p(destination_dir)
    kde_dir = options[:kde_dir].gsub("~", ENV["HOME"])
    unless File.directory?(ktorrent_dir(kde_dir))
      raise "%s not a directory" % ktorrent_dir
    end
    unless File.directory?(destination_dir)
      raise "%s not a directory" % destination_dir
    end
    file_list(kde_dir).each do |file_name|
      torrent = BEncodr.bdecode_file(file_name)
      torrent_name = torrent["info"]["name"]
      FileUtils.cp(file_name, File.join(destination_dir, "#{torrent_name}.torrent"))
    end
  end
end
