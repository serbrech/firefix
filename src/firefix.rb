require 'fileutils'

class Firefix

  def backup_already_there_message file_path
    puts red("there is already a file named #{file_path}.#{CONFIG[:backup_extension]}. this probably means that the fix has already been applied.")
  end

  def backup_file_exist? file_path
     if File.exists?("#{file_path}.#{CONFIG[:backup_extension]}")
      backup_already_there_message(file_path)
      return true
    end
    return false
  end

  def backup_file file_path
    return false if backup_file_exist? file_path
    puts "backing up #{file_path}"

    FileUtils::touch(file_path);
    FileUtils::cp(file_path, "#{file_path}.#{CONFIG[:backup_extension]}") unless File.exists?("#{file_path}.#{CONFIG[:backup_extension]}")
    puts green("back up done")
    return true
  end

  def process_js js_path
    puts "\n#{js_path}" 
    return if backup_file_exist? js_path

    backup_file js_path

    File.open(js_path, 'a+') do |file|
      file.write(DATA[:js_content])
    end
    puts green("#{js_path} patched!")
  end

  def process_rdf rdf_path
    puts "\n#{rdf_path}"
    unless File.exist? rdf_path
      FileUtils::cp "src/mimeTypes.rdf", rdf_path
    end

    return if backup_file_exist? rdf_path
    backup_file rdf_path
    close_tag = "</RDF:RDF>"
    data = ""
    File.open(rdf_path, "r").each_line do |l| 
      data += l
    end
    
    File.open(rdf_path, "w") do |f|
      f.write(data.gsub(close_tag, "#{DATA[:rdf_content]}#{close_tag}"))
    end
    puts green("mimeTypes.rdf patched!")
  end

  def process_profile path
    puts "\nProcessing profile #{path}"
    prefs_path = "#{path}/prefs.js"
    js_path = "#{path}/user.js"
    rdf_path = "#{path}/mimeTypes.rdf"

    debug "backup prefs.js"
    backup_file(prefs_path)

    debug "processing user.js"
    process_js(js_path)

    debug "processing rdf"
    process_rdf(rdf_path)
  end

  def rollback file_path
    puts "rolling back #{file_path}"
    backup_file = "#{file_path}.#{CONFIG[:backup_extension]}"
    if(File.exists?(backup_file))
      File.rename( backup_file, "#{file_path}" ) 
    else
      puts red("could not find backup for #{file_path}")
    end
  end

  def rollback_profiles profile
    puts "rolling back #{profile}"
    rollback("#{profile}/prefs.js")
    rollback("#{profile}/user.js")
    rollback("#{profile}/mimeTypes.rdf")
    puts "rollback done"
  end

  def process_or_rollback_profile profile
    profile_path = "#{CONFIG[:profiles_path]}/#{profile}"
    debug "#{profile_path}"
    if ARGV.first == "rollback" 
      rollback_profiles(profile_path)
    else 
      process_profile(profile_path)
    end
  end
  
  def run
    Dir.foreach(CONFIG[:profiles_path]) do |profile|
      unless CONFIG[:exluded_folders].include?(profile)
        process_or_rollback_profile profile
      end
    end
  end

end

