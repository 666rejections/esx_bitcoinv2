fx_version 'adamant'

game 'gta5'

description 'ESX Bitcoin V2 - By Jordan'

version '2.0.0'

server_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'server/main.lua',
	'config.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'client/main.lua'
}
