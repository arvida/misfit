#
#  ****      ****
#  *****    *****            ************* ************* 
#  *****    ***** ***    ****   *****    ***  ******  
#  ******  ****** ****  *******  ***     ****  **** 
#  ************** **** ****   ** ******* ***   *** 
#  *** ****** *** ****  *****    ******  ***   *** 
#  ***  ****  ***  ***     ****  ***     ****  *** 
#  ***  ****  ***  *** ***   *** ***     ****  *** 
#  * *   **    **  **    ******  ***     ***   ** 
#              *                *       **
#

require 'rubygems'
require 'thor'
require 'yaml'
 
class Misfit < Thor
  VERSION = "0.1.1"
  
  desc "misfit version", "Prints version information"
  def version
    puts "Misfit v#{VERSION}"
  end
  
  desc "misfit import GIT_REPOSITORY_URL DESTINATION", "Import GIT_REPOSITORY_URL to DESTINATION"
  method_options :branch => :string
  def import(repository_url, destination)
    if not File.exists?(destination)
      puts "Importing #{repository_url} to #{destination}"
      if import_repository(repository_url, destination, options[:branch])
        puts 'Imported repository'
        puts `svn status #{destination}` if svn_project?
      else
        puts "Unable to clone #{repository_url}"
      end
    else
      puts "#{destination} already exists"
    end
  end
  
  desc "misfit update DESTINATION", "Update previously exported git repository at DESTINATION"
  def update(destination)
    dest_config = config_for_path(destination)
    if dest_config and dest_config['repository_url']
      puts "Importing updates from #{dest_config['repository_url']} to #{destination}"
      if update_repository(dest_config['repository_url'], destination, dest_config['branch'])
        puts 'Updated repository'
        puts `svn status #{destination}` if svn_project?
      else
        "Unable to update #{destination} from #{dest_config['repository_url']}"
      end
    else
      puts "Unable to open #{destination}/.misfit.yaml"
    end
  end
  
protected

  def svn_project?
    @svn_project ||= File.exists?('.svn')
  end

  def config_for_path(path)
    settings_file = File.join(path, '.misfit.yaml')
    if File.exists?(settings_file)
      YAML::load(File.read(settings_file))
    end
  end
  
  def import_repository(repository_url, destination, branch = nil)
    `git clone #{repository_url} #{destination}`
    if branch
      `cd #{destination};git checkout -b #{branch} origin/#{branch}`
    end
    if $?.to_i == 0
      `rm -Rf #{destination}/.git`
      File.open(File.join(destination, '.misfit.yaml'), 'w') do |f|  
        f.puts({ 'repository_url' => repository_url, 'branch' => branch }.to_yaml)
      end
      `svn add #{destination}` if svn_project?
      return true
    end
    false
  end
  
  def update_repository(repository_url, destination, branch = nil)
    tmp_dest = File.dirname(destination)+'_tmp'
    `git clone #{repository_url} #{tmp_dest}`
    if branch
      `cd #{tmp_dest};git checkout -b #{branch} origin/#{branch}`
    end
    if $?.to_i == 0
      sync_directories(destination, tmp_dest)
      `rm -Rf #{tmp_dest}` and return true
    end
    false
  end
  
  def sync_directories(old_directory, new_directory)    
    old_directory_paths = Dir["#{old_directory}/**/**"].find_all { |file| File.basename(file)[0] != "." }
    new_directory_paths = Dir["#{new_directory}/**/**"].find_all { |file| File.basename(file)[0] != "." }
    old_directory_paths.each do |path|
      new_path = path.gsub(/^#{old_directory}\//, new_directory+'/')
      unless new_directory_paths.include?(new_path)
        puts `svn remove #{path}` if svn_project?
        `rm -rf #{path}`
      end
    end
    new_directory_paths.each do |path|
      new_path = path.gsub(/^#{new_directory}\//, old_directory+'/')
      do_add = false
      if not File.exists?(new_path)
        do_add = true
      end
      if File.directory?(path)
        if do_add
          `mkdir #{new_path}`
        end
      else
        `cp -f #{path} #{new_path}`
      end
      if do_add
        `svn add #{new_path}` if svn_project?
      end
    end
  end
end