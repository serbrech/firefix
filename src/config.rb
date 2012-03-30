# encoding: UTF-8
CONFIG = {
  :backup_extension => 'pp3.backup',
  :home_path => ENV['HOME'],
  :profiles_path =>"#{ENV['HOME']}/Library/Application Support/Firefox/Profiles",
  :exluded_folders =>[".", "..", ".DS_Store"]
}

CONFIG.merge!(USER_CONFIG)


DATA = {
  :rdf_content => %Q[
    <RDF:Description RDF:about="urn:mimetype:externalApplication:application/x-indesign"
       NC:path="/Applications/Adobe InDesign #{CONFIG[:indesign_version]}/Adobe InDesign #{CONFIG[:indesign_version]}.app"
       NC:prettyName="Adobe InDesign #{CONFIG[:indesign_version]}" />
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
  ],
  :js_content => %Q[
  user_pref("capability.policy.policynames", "pageplanner");
  user_pref("capability.policy.pageplanner.sites","#{CONFIG[:pageplanner_url]}");
  user_pref("capability.policy.pageplanner.checkloaduri.enabled", "allAccess");
  ]
}



