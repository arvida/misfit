$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'test/test_helper'
require 'lib/misfit'

class MisfitTest < Test::Unit::TestCase
  context "A misfit instance" do
    setup do
      @misfit = Misfit.new
      @repository_path = File.join(project_path,'tmp','test')
      `mkdir #{@repository_path}`
      `echo "Test text file 1" > #{File.join(@repository_path,'one.txt')}`
      `echo "Test text file 2" > #{File.join(@repository_path,'two.txt')}`
      `cd #{@repository_path} && git init && git add . && git commit -a -m "Init commit"`
    end
    
    teardown do
      `rm -rf #{File.join(project_path,'tmp','*')}`
    end

    should "return its version" do
      out = capture_stdout do 
        @misfit.version 
      end
      assert_equal "Misfit v#{Misfit::VERSION}\n", out.string
    end
    
    context "when importing a repository" do
      setup do
        @import_path = File.join(project_path,'tmp','import')
        @misfit.import(@repository_path, @import_path)
      end
      should "add files from repository to import path" do
        assert File.exists?(@import_path)
        assert File.exists?(File.join(@import_path,'one.txt'))
        assert File.exists?(File.join(@import_path,'two.txt'))
      end    
      
      should "create a .misfit.yaml file with repository path" do
        assert File.exists?(File.join(@import_path,'.misfit.yaml'))
        settings = YAML::load(File.read(File.join(@import_path,'.misfit.yaml')))
        assert_equal @repository_path, settings['repository_url']
      end
    end
    
    context "when updating a project" do
      setup do
        @import_path = File.join(project_path,'tmp','import')
        @misfit.import(@repository_path, @import_path)
        `mkdir #{File.join(@repository_path,'sub_folder_one')}`
        `mkdir #{File.join(@repository_path,'sub_folder_two')}`
        `echo "Test text file 3" > #{File.join(@repository_path,'sub_folder_one','three.txt')}`
        `echo "Test text file 1" > #{File.join(@repository_path,'sub_folder_two','one.txt')}`        
        `echo "Test text file 2" > #{File.join(@repository_path,'sub_folder_two','two.txt')}`        
        `cd #{@repository_path} && git add . && git commit -a -m "Added more test content"`
        @misfit.update(@import_path)
      end
      
      should "add new files and folders" do
        assert File.exists?(File.join(@import_path,'sub_folder_one'))
        assert File.exists?(File.join(@import_path,'sub_folder_two'))
        assert File.exists?(File.join(@import_path,'sub_folder_one','three.txt'))
        assert File.exists?(File.join(@import_path,'sub_folder_two','one.txt'))
        assert File.exists?(File.join(@import_path,'sub_folder_two','two.txt'))
      end
          
      should "delete removed files and folders" do
        `cd #{@repository_path} && git rm -r sub_folder_one`
        `cd #{@repository_path} && git rm -r sub_folder_two/two.txt`
        `cd #{@repository_path} && git commit -a -m "Removed some test content"`
        @misfit.update(@import_path)
        assert !File.exists?(File.join(@import_path,'sub_folder_one'))
        assert !File.exists?(File.join(@import_path,'sub_folder_two','two.txt'))
      end
    end
  end
end
