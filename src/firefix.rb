require 'fileutils'

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end
def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end

def debug text
  puts text if $-v
end

debug green("VERBOSE MODE!")

class Firefix

  def backup_file file_path
    puts "backing up #{file_path}"

    if File.exists?("#{file_path}.#{CONFIG[:backup_extension]}") 
      backup_already_there_message(file_path)
      return false
    end
    FileUtils::touch(file_path);
    FileUtils::cp(file_path, "#{file_path}.#{CONFIG[:backup_extension]}") unless File.exists?("#{file_path}.#{CONFIG[:backup_extension]}")
    puts green("back up done")
    return true
  end

  def backup_already_there_message file_path
    puts red("there is already a file named #{file_path}.#{CONFIG[:backup_extension]}. this probably means that the fix has already been applied.")
  end

  def process_js js_path
    puts "\n#{js_path}" 

    return unless backup_file(js_path)

    File.open(js_path, 'a+') do |file|
      file.write(DATA[:js_content])
    end
    puts green("#{js_path} patched!")
  end

  def process_rdf rdf_path
    puts "\n#{rdf_path}"
    
    return unless backup_file(rdf_path) 
    
    close_tag = "</RDF:RDF>"
    data = ""
    File.open(rdf_path, "r").each_line do |l| 
      data += l
    end
    
    File.open(rdf_path, "w") do |f|
      f.write(data.gsub(close_tag, "#{DATA[:rdf_content]}#{close_tag}"))
    end
    puts green("mimetypes.rdf patched!")
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

