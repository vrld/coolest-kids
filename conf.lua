function love.conf(t)
	t.title             = "Cool Kids on The Block"
	t.author            = "vrld"
	t.url               = "http://vrld.org/"
	t.identity          = "vrld-cool-kids-on-the-block"
	--t.release           = true

	t.modules.physics   = false

	t.screen.width      = 800
	t.screen.height     = 600
	t.screen.fullscreen = false
	t.screen.fsaa       = 0
	t.screen.vsync      = false
end
