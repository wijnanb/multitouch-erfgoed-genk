window.config =
	host: "http://localhost:8888/genk/multitouch-erfgoed-genk/"
	screen_width: 1920
	screen_height: 1080
	block:
		width: 130
		height: 130
	grid_size:
		x: 14
		y: 8
	region_size:
		x: 6
		y: 3
	region_positions:
		TOP_LEFT:
			x: 0, y: 0
		TOP:
			x: 4, y: 0
		TOP_RIGHT:
			x: 8, y: 0
		BOTTOM_LEFT:
			x: 0, y: 5
		BOTTOM:
			x: 4, y: 5
		BOTTOM_RIGHT:
			x: 8, y:5
	debug_grid: true
	folder:
		box_size:
			x: 130
			y: 130

### calculate block size

width: 1920 - 2*20 = 1880
height: 1080 - 2x20 = 1040

grid_size: 14x8
-->  1880/14 = 134,285714286
-->  1040/8 = 130

1920 - 14*130 = 100 --> 50 marge links en rechts 

==> full block size: 260x260


Regions:

==> region size:   6x3 blocks  = 780x390
==> folder: 4x3 blocs = 520x390

take some margin and must be divideable by 4x3







###