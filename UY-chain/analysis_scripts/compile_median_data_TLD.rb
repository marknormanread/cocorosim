#
# This is a "top level driver" (TLD) for the compile_median_data.m matlab script. It is designed to be executed from a directory which
# itself contains sub-directories containing experimental data. Each sub-directory might represent, for example, a sample in parameter
# space. The script identifies all sub-directories which contain cocorosim output data, copies compile_median_data.m into the directory
# and executes it therein. 


require 'fileutils'


path = Dir.pwd
k = path.rindex('cocorosim')
headDir = path[0..k-1]

dataPrefix = 'cocorosim-output_-_'

compileScript = headDir + '/cocorosim/boids6-profiling/output/analysis_scripts/compile_median_data.m'


dataPrefix = 'cocorosim-output_-_'


dirs = Dir.entries('.').reject!{|i| File.directory?(i) == false}     # retrieve all immediate directory contents, and keep only the directories. 
dirs.reject! do |i|                        # identify and keep only those directories which contain cocorosim output data files
  reject = true                            # default action is to reject directory. This is overruled as soon as a file containing simulation data is found. 
  files = Dir.entries(i)
  files.each do |f|
    if f.index(dataPrefix) != nil
      reject = false
      break
    end
  end
  reject
end

dirs.sort!



cwd = Dir.pwd()                                                       # store the current working directory such that we can get back again. 
dirs.each do |dir|
  puts "compiling median data in directory : " + dir
  Dir.chdir dir
  FileUtils.ln_s(compileScript, '.', :force => true)
  system("matlab -nosplash -nodesktop -nodisplay -r \"compile_median_data;quit\"")
  Dir.chdir cwd
end
