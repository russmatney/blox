extends GdUnitTestSuite

## basic tick ############################################

func test_basic_tick_settles_board():
	var grid = BloxGrid.new({width=2, height=3})
	var bucket = auto_free(BloxBucket.new())
	bucket.grid = grid
	bucket.tick_every = 0.0

	var p = BloxPiece.new({cells=[Vector2i()], coord=Vector2i(1, 0)})
	var ret = grid.add_piece(p)
	assert_bool(ret).is_true()

	bucket.tick()

	var crds = grid.piece_coords()
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(1, 2)])
