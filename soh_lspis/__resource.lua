resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
description "Los Santos Police Information System (LSPIS) - HF Creations for SoH"
version "1.0.0"

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'lspis_server.lua'
}

client_scripts {
	'config.lua',
	'lspis_client.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/tablet.png',
    'html/js/nui_controls.js'
}