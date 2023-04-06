fx_version 'cerulean'
game 'gta5'
description 'Eric Holdup Job'

author 'AiReiKe'
version '1.1.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua'
	'config.lua',
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/*.lua'
}
