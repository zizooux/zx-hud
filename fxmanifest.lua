
fx_version 'cerulean'
game 'gta5'
author "zizooux"
description 'zizooux'

version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_script 'client/*.lua'   -- includes Main.lua AND camera.lua
server_script 'Server/*.lua'
ui_page 'html/index.html'
files {
'html/*.html',
'html/*.css',
'html/*.js'
}

dependency '/assetpacks'
