require 'fileutils'

@indesign_version = "CS5" #edit this to match the indesign version CS5 or CS5.5
@pageplanner_url = "http://demo.pageplannersolutions.com" #edit this url, this can also use the ip address, every url should be space separated.
@backup_extension = "pp3.backup"
@home_path = ENV['HOME']
@profiles_path = "#{@home_path}/Library/Application Support/Firefox/Profiles"
@exluded_folders = [".", "..", ".DS_Store"]
@rdf_content = %Q[
  <RDF:Description RDF:about="urn:mimetype:externalApplication:application/x-indesign"
     NC:path="/Applications/Adobe InDesign #{@indesign_version}/Adobe InDesign #{@indesign_version}.app"
     NC:prettyName="Adobe InDesign #{@indesign_version}" />
    <RDF:Description RDF:about="urn:mimetype:application/x-indesign"
     NC:fileExtensions="indd"
     NC:description="InDesign"
     NC:useSystemDefault="true"
     NC:value="application/x-indesign"
     NC:editable="true">
  <NC:handlerProp RDF:resource="urn:mimetype:handler:application/x-indesign"/>
    </RDF:Description>
  <RDF:Description RDF:about="urn:mimetype:handler:application/x-indesign"
     NC:alwaysAsk="false"
     NC:saveToDisk="false"
     NC:useSystemDefault="false"
     NC:handleInternal="false">
  <NC:externalApplication RDF:resource="urn:mimetype:externalApplication:application/x-indesign"/>
  </RDF:Description>
]

@js_content = %Q[
user_pref("capability.policy.policynames", "pageplanner");
user_pref("capability.policy.pageplanner.sites","#{@pageplanner_url}");
user_pref("capability.policy.pageplanner.checkloaduri.enabled", "allAccess");
]

def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
end
def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end

def debug text
  puts text if $-v
end

debug green("VERBOSE MODE!")

def backup_file file_path
  puts "backing up #{file_path}"

  if File.exists?("#{file_path}.#{@backup_extension}") 
    backup_already_there_message(file_path)
    return false
  end
  FileUtils::touch(file_path);
  FileUtils::cp(file_path, "#{file_path}.#{@backup_extension}") unless File.exists?("#{file_path}.#{@backup_extension}")
  puts green("back up done")
  return true
end

def backup_already_there_message file_path
  puts red("there is already a file named #{file_path}.#{@backup_extension}. this probably means that the fix has already been applied.")
end

def process_js js_path
  puts "\n#{js_path}" 

  return unless backup_file(js_path)

  File.open(js_path, 'a+') do |file|
    file.write(@js_content)
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
    f.write(data.gsub(close_tag, "#{@rdf_content}#{close_tag}"))
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
  backup_file = "#{file_path}.#{@backup_extension}"
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

Dir.foreach(@profiles_path) do |profile|
  unless @exluded_folders.include?(profile)
    profile_path = "#{@profiles_path}/#{profile}"
    debug "#{profile_path}"
    if ARGV.first == "rollback"
      rollback_profiles(profile_path)
    else
      process_profile(profile_path)
    end
    puts
  end
end