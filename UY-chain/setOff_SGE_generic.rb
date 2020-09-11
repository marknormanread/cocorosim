#========================
#
# Script for setting off boids parameter investigation experimentation on a cluster. 
# Script can prepare jobs for three clusters - cosmos, sebase and maven. 
#   The cluster to be used must be specified as a command line argument when calling this script
# This script is generic, and can be used to set off many kinds of experiments. The exact details
#   concerning which parameters are to be varied, their values, locations to which data is written
#   and where xml files driving behaviourspace are located have to be provided in a second
#   ruby source file. The location of this source file is provided as the second command line 
#   argument. 
# The script creates two sets of files: netlogo xml files containing specifics of particular
#   executions to be carried out; and sun grid engine job script files that execute them. 
# The script is capable of determining whether a job has previously been carried out, and if
#   this is found to be the case, the sun grid engine script will not run the netlogo execution. 
#   This is determined by searching for the output file that would otherwise be generated. If it is 
#   not present, then the job runs. This is a powerful feature: if jobs fail for whatever reason, 
#   rather than having to identify which jobs failed and re-submit only the missing items, an 
#   entire array job SGE script can be re-run, and only the failed jobs will re-run. 
#
# An example usage of this script:
#   $> ruby ../../setOff_SGE_generic.rb -cosmos setOff_SGE.rb
#========================

require 'fileutils'

cluster = "non"    # this has to be either "cosmos" or "sebase"

if ARGV.length < 2
  raise "you must supply the cluster name: -cosmos or -sebase. You must also supply a path to the file containing parameter/cluster experimentation details."
end

arg = ARGV[0]
expdir = "UY-chain2/"
puts arg
if arg == '-cosmos'
  cluster = "cosmos"
  loc = "cocorosim/" + expdir
end 
if arg == '-sebase'
  cluster = "sebase"
  loc = "/n/sebase/markread/cocorosim/" + expdir
end
if arg == '-maven'
  cluster = "maven"
  loc = "cocorosim/" + expdir
end


#========================
# Read in the parameter/experiment specific data file, which contains the following
# variables. 
detailsFilePath = ARGV[1]    # the second command line argument should be to the ruby file containing
                             # details concerning parameter names, locations, and values. 
#
# $paramName - the name of the parameter, as it appears in the netlogo code, and hence directories.
# $paramShort - a short encoding of what the parameter name is, usually just concatenated initials.
# $total_ticks - how many ticks of the simulation are performed before an execution terminates. 
# $numRuns - how many executions are to be performed for each parameter value. 
# $outputSubDir - directory name where output is to be written, eg, output6 or outputGlobal.
# $values - an array of strings, representing the parameter values to be set.
# 
load detailsFilePath 
#========================

submit_jobs = false           # whether or not the job scripts generated here should be 
                              # immediately submitted
if ARGV.length > 2
  if ARGV[2] == "-submit"
    submit_jobs = true
  end
end

scripts = []  # store script file names so they can be submitted to SGE after
seed = 0
if not File.exists?('seeds')
  system "echo 0 > seeds"
end

File.open('seeds','r') do |f|
	seed = f.gets.to_i
	puts seed
end

# make the following directories, if they do not already exist
unless File.directory?('SGE')
  FileUtils.mkdir_p('SGE')
end

unless File.directory?('param_files')
  FileUtils.mkdir_p('param_files')
end

# cocorosim output names are stored in these variables. 
$values.each do |val|
	# the nearly full sim output file name, missing the run number from the end of it. 	
	outputFileNameShort = $outputSubDir + "/" + $paramName + "/val_-_" + val \
				                + "/cocorosim-output_-_" + $paramShort + "_-_"

       
  if File.exists?("val_-_" + val) == false
    system("mkdir val_-_" + val)
  end


  paramFileName = "param_files/param_-_" + $paramName + "_-_" + val + ".xml"
  File.open(paramFileName, 'w') do |pf|
    pf.puts "<?xml version=\"1.0\" encoding=\"us-ascii\"?>"
    pf.puts "<!DOCTYPE experiments SYSTEM \"behaviorspace.dtd\">"
    pf.puts "" 
    pf.puts "<experiments>"
         
    (1..$numRuns).each do |runNum|
	    outputFileNameFull = outputFileNameShort + runNum.to_s # full sim output data file name

          pf.puts "<experiment name=\"run_" + runNum.to_s + "\" repetitions=\"1\" runMetricsEveryStep=\"false\">"
          pf.puts "<setup>"
          pf.puts "  setup"
          pf.puts "  set EO-output-file \"" + outputFileNameFull + "\""
          pf.puts "  random-seed " + seed.to_s
          pf.puts "  set " + $paramName + " " + val
          pf.puts "</setup>"
          pf.puts "<go>go</go>"
          pf.puts "<final>experiment-teardown</final>"
          pf.puts "<exitCondition>ticks >= " + $total_ticks.to_s + "</exitCondition>"
          pf.puts "</experiment>"
          pf.puts ""
          seed = seed + 1
    end
    pf.puts "</experiments>"        
  end



  scriptPrefix = "SGE/" + $paramShort + "_" + val        # one SGE script for each parameter value
  scriptName = scriptPrefix + ".sge"
  scripts<< scriptName
  File.open(scriptName,'w') do |sge|

    sge.puts "#!/bin/sh"
    sge.puts "#\$-S /bin/bash"
    sge.puts "# This is an array job."
    sge.puts "#\$ -t 1-" + $numRuns.to_s
    if cluster == "cosmos"
      sge.puts "#\$ -l virtual_free=2.5G"
    elsif cluster == "maven"
	    sge.puts "#\$ -l virtual_free=2.5G"
    elsif cluster == "sebase"
      sge.puts "#\$ -l mem_free=2G,mem_total=30G"
    end
    sge.puts "#\$ -N " + $paramShort + "-" + val
    sge.puts "#\$ -o " + loc + $outputSubDir + "/" + $paramName + "/" + scriptPrefix + ".out"  
    sge.puts "#\$ -e " + loc + $outputSubDir + "/" + $paramName + "/" + scriptPrefix + ".err"  
    sge.puts "let \"RUNNUM=(($SGE_TASK_ID))\""

    sge.puts "cd " + loc
	  sge.puts "if [ ! -f " + outputFileNameShort + "$RUNNUM ]" # only run sim if file doens't exist
	  sge.puts "then"
      sge.write "  "
      if cluster == "cosmos"
        sge.write "/usr/bin/java"
      elsif cluster == "maven"
        sge.write "/usr/bin/java"
      elsif cluster == "sebase"
        sge.write "/usr/lib/java/bin/java"
      end
      sge.write " -Dorg.nlogo.is3d=true"
      if cluster == "cosmos"
        sge.write " -Xmx2500M -XX:MaxPermSize=256M "
      elsif cluster == "maven"
	      sge.write " -Xmx2500M"
      elsif cluster == "sebase"
        sge.write " -Xmx1500M"
      end
      sge.write " -cp NetLogo.jar org.nlogo.headless.Main"
      sge.write " --model CoCoRoSim.nlogo"
      sge.write " --setup-file " + $outputSubDir + "/" + $paramName + "/param_files/param_-_" \
                 + $paramName + "_-_" + val + ".xml"
      sge.write " --experiment run_$RUNNUM"
	    sge.write "\n"
	  sge.puts "fi"
  end
end

if submit_jobs
  scripts.each do |s|
    if cluster == "cosmos"
      system("qsub " + s)
    elsif cluster == "sebase"
      system("qsub -q all.q " + s)
    elseif cluster == "maven"
      system("qsub -q all.q " + s)
    end
  end
end

File.open('seeds','w') do |f|
	f.puts seed.to_s
end

