RubyGem

Error:  couchrest extended error "404 Resource Not Found", RestClient::ResourceNotFound, {"error":"not_found","reason":"missing"} 
Fix: Refresh your design documents. In script console DocumentModelName.refresh_design_doc for each design document
  * with couchclient, run rake couch:sync
  