#
# Script is intended to handle end-to-end the robustness OAT analysis. 
# Two arguments can be provided, '-default' though which the default parameter value is specified
# and '-units' which are the units to appear on the axis labels. The default value can also be 
# specified as the sole contents of a file name 'defaultParameterValue'
# 
# Script will delete the old folder containing the analysis, and create a new one. 
# The script will exlude directories which do not contain a complete set of data, determined
# through examination of the 'consistencyOfData' file (should it exist)
#
#



require 'fileutils'



# The following will dynamically calculate the absolute path to the current cocorosim experimental set up, 
# used in copying files across to places where they are later executed. 
path = Dir.pwd
k = path.rindex('output')
headDir = path[0..k-1]
puts headDir



$defaultParameterValueFileName = "defaultParameterValue"      # the name of the file (should it exist) that contains the default parameter value. 
cocorosimDataFilePrefix = 'cocorosim-output'                        # all cocorosim data files start with this prefix


#---------------------------------------
# Read command line arguments. 
defaultValue = ''
units = ''
defaultProvided = false
for i in (0..ARGV.length)
  arg = ARGV[i]
  puts arg #"arg " + i.to_s + " = " + arg.to_s
  if arg == '-default'  
    defaultValue = ARGV[i+1]
    defaultProvided = true
  end
  if arg == '-units'
    units = ARGV[i+1]
  end
end
#---------------------------------------



#---------------------------------------
# This method was obtained from http://www.devdaily.com/blog/post/ruby/ruby-method-read-in-entire-file-as-string on 25/11/09
#
# retrieves an entire file's data as a string, 'data', which is then returned. 
def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end
#---------------------------------------



#---------------------------------------
#---------------------------------------
#
# ENTRY POINT INTO THE PROGRAM
#
#---------------------------------------
#---------------------------------------




# create the directory where all the crude sensitivity analysis response data is to be copied. 
robustnessDir = "robustness_sensitivity_analysis"
if !File.exists?(robustnessDir)
  FileUtils.mkdir(robustnessDir)
#  FileUtils.rm_rf(robustnessDir)
end


# find the default value that the parameter would take.
if defaultProvided == false
  if File.exists?($defaultParameterValueFileName)
    defaultValue = File.open($defaultParameterValueFileName,"r"){|f| defaultValue = f.gets}
  else
    throw "cannot ascertain default value for this experiment!"
  end
end
puts "default value = " + defaultValue


pathArray = Dir.entries(".").reject!{|i| File.directory?(i) == false}     # keep only directories. 
pathArray.reject! do |i|                                                  # remove all directories that do not contain cocorosim data
  reject = true
  files = Dir.entries(i)
  files.each do |f|
    if f.index(cocorosimDataFilePrefix) != nil
      reject = false
      break
    end
  end
  reject                                 # 'return' value for rejection
end

#----------------------------------
# looks to open the consistency of data file. 
# If the file contains the word "FAIL", then it is excluded from the present analysis. 
pathArray.reject! do |i|                              
  reject = false                                                          # the default case
  if File.exists?(i + "/consistency_of_data_result")
    print "consistency of data file exists... reading contents..."
    File.open(i + "/consistency_of_data_result") do  |file|
      while (line = file.gets)
        if line.index("FAIL") != nil
          reject = true
          print " rejecting directory " + i
          break                         # stop after first occurance
        end
      end
      puts ""
    end
  end
  reject                                # 'return' value for rejection
end
#----------------------------------


pathArray.sort!                                                           # operate on directories in a slightly more sensible manner.  
pathArray.each{|i| i.insert(0, FileUtils.pwd() + "/")}                    # turn the relative address into the absolute address. This is important because
                                                                          # there is information encoded in the directory names. 

# output to the terminal which files have been found.
puts("\n\nthe following directories were identified\n\n")
pathArray.each do |item|
  puts(item)
end



pathArray.each do |path|
  puts "compiling single run data from directory : " + path               # keep the user informed

  paramTestValue = path[path.rindex("_")+1..-1]											# retrieves the value of the parameter during this set of runs, as derived from 'path'. 
  outputDataFileName = "cocorosim-responses_-_"                     # begin creating the output file name. 
  outputDataFileName += paramTestValue		                          # compile the name of the file to which response data is to be written.
 
  cwd = Dir.pwd
  Dir.chdir path                                                    # compile the distributions. 
    FileUtils.ln_s(headDir + 'analysis_scripts/generate_response_distributions.m', '.', :force => true)
    system("matlab -nosplash -nodesktop -r \"generate_response_distributions('" + outputDataFileName + "');quit\"")  
  Dir.chdir cwd

  FileUtils.cp(path + '/' + outputDataFileName, robustnessDir + '/' + outputDataFileName);

  # if this parameter happens to be the default parameter, then recompile and save as a name corresponding to the 'default'. 
  if (paramTestValue.to_f == defaultValue.to_f)
    fileName = robustnessDir + "/" + "cocorosim-responses_-_"       # start creating the file name for the default response data.
    fileName += "default_-_" + defaultValue                         # add the "default" keyword and the value itself.
    FileUtils.cp(path + '/' + outputDataFileName, fileName);
  end
end

Dir.chdir('robustness_sensitivity_analysis')
  FileUtils.ln_s(headDir + 'analysis_scripts/robustness_analysis.m', '.', :force => true)
  system('matlab -nodesktop -nosplash -r "robustness_analysis(\'-units ' + units + '\');quit"')
Dir.chdir('..')



