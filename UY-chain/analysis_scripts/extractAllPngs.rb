# This script will find all the png files within the current directory (intended to be the parameter_analysis directory) and will 
# copy all of them, maintaining the directory stuctures from whence they came, into a directory called 'allPngs'
#
# This is useful for extracting graphs away from the data that generated them, such that they may be handled in the thesis. 

require 'find'
require 'fileutils'


if true
  system("rm -r allPngs")

  root = Dir.pwd

  files = []
  robustnessIndexFiles = []
  Find.find('.') do |path| 
    if path[-4 .. -1] == ".png"  
      files<< path
    end
    if path.index('robustness_indexes_-_') != nil
      robustnessIndexFiles<< path
    end
  end

  system("mkdir allPngs")
  system("mkdir allPngs/robustness_indexes")

end
  
if true  
  files.each do |f|
    puts f

    filename = f[f.rindex('/') + 1 .. -1]
    path = f[ 2 .. f.rindex('/')-1 ]
    
    if File.exists?("allPngs/" + path) == false
      FileUtils.mkdir_p("allPngs/" + path)
    end
    src = path + "/" + filename
    dst = "allPngs/" + path + "/" + filename
    FileUtils.cp(src,dst)
  end
end


# this code here will copy all the robustness_indexes files into the allPngs directory. 
if true
  robustnessIndexFiles.each do |path|
    filename = path[path.rindex("/")+1 .. -1]
    filepath = path[2 .. path.rindex("/")]
    if File.exists?(filepath) == false
      system("mkdir " + filepath)
    end
    puts path
    FileUtils.cp(path, "allPngs/robustness_indexes/" + filename)
  end
end

Dir.chdir("allPngs/robustness_indexes")
path = Dir.pwd
k = path.rindex('Treg_2D')
headDir = path[0..k-1]                                              # dynamically find the location of this experimental set up. 

summariseScriptLoc = headDir + '/Treg_2D/data_analysis/robustnessAnalysis/summarise_robustness_indexes.m'
FileUtils.ln_s(summariseScriptLoc, '.', :force => true)
system("matlab -nodesktop -nosplash -r \"summarise_robustness_indexes;quit\"")
