#
# This is a "top level driver" (TLD) for the check_consistency_of_data_files.m script. It is designed to be run in a directory which contains other directories
# that contain simulation data files. For example: a directory containing parameter sweep data, with each increment in parameter space represented by a 
# sub-directory. 
#
# The scriopt locates all the directories that contain simulation data, and copies and runs the matlab script in each of them. 
#
# The script REQUIRES one command line argument: "-numRuns XXX", which specifies how many simulation execution files are expected in each sub-directory. 


require 'fileutils'

numRuns = -1                        # must be specified, so default is nonsensical number.

if ARGV.length == 0
  raise "you must supply the number of simulations runs expected in each experiment"
end

for i in (0..ARGV.length)
  arg = ARGV[i]
  puts arg
  if arg == '-numRuns'
    numRuns = ARGV[i+1]
  end 
end

path = Dir.pwd
k = path.rindex('cocorosim')
headDir = path[0..k-1]

dataPrefix = 'cocorosim-output_-_'

consistencyScript = headDir + '/cocorosim/boids6-profiling/output/analysis_scripts/check_consistency_of_data_files.m'

dirs = Dir.entries('.').reject!{|i| File.directory?(i) == false}     # retrieve all immediate directory contents, and keep only the directories. 
dirs.reject! do |i|
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

allDirs = dirs

#---------------------------------------------
# This section will remove any directories that contain the file 'consistencyOfDataResult', but only if that file does not contain the
# word 'FAIL'. Failed directories should be re-checked. 
if false
  dirs.reject! do |dir|
    remove = false                          # default case, don't remove. 
    if File.exists?(dir + '/consistency_of_data_result')
      remove = true                         # if this file already exists, then by default we will reject the directory and not run the check again. 
                                            # However, first the file is read, to see if the directory failed the previous check. 
      File.open(dir + '/consistency_of_data_result') do |file| 
        while (line = file.gets)            # read lines until there are no more to be read. 
          if line.index('FAIL') != nil     # check to see if the word "fail" appears in the file. 
            remove = false
            break
          end
        end
      end
    end
    remove
  end
end
#---------------------------------------------



cwd = Dir.pwd()                                                       # store the current working directory such that we can get back again. 
dirs.each do |dir|
  puts "checking consistency of data in directory : " + dir
  Dir.chdir dir
  FileUtils.ln_s(consistencyScript, '.', :force => true)
  system("matlab -nosplash -nodesktop -nodisplay -r \"check_consistency_of_data_files('-numRuns " + numRuns + "');quit\"")
  Dir.chdir cwd
end


failed = false
failedDirs = []
allDirs.each do |dir|
  File.open(dir + '/consistency_of_data_result','r') do |file|
    while (line = file.gets)
      if line.index('FAIL') != nil
        failed = true 
        failedDirs<< dir
      end
    end 
  end
end

if dirs.length != 0
  File.open('consistency_of_data_result','w') do |file|
    if failed == false
      file.write( "PASS\n" )
    else
      failedDirs.each do |dir|
        file.write( "FAIL - " + dir + " \n" )
        end
      end
    file.write("-numRuns " + numRuns)
    end
  end
