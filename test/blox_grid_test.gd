extends GdUnitTestSuite

## grid coords ############################################

func test_all_coords():
	var grid = BloxGrid.new({width=3, height=4})
	var coords = grid.all_coords()
	assert_int(len(coords)).is_equal(3*4)
	assert_array(coords).contains([Vector2i(0, 0)])

func test_all_coords_as_dict():
	var grid = BloxGrid.new({width=3, height=4})
	var dict = grid.all_coords_as_dict()
	assert_int(len(dict.keys())).is_equal(3*4)
	assert_that(dict[Vector2i(0, 0)]).is_false()
	assert_that(dict[Vector2i(0, 3)]).is_false()
	assert_that(dict[Vector2i(2, 0)]).is_false()
	assert_that(dict[Vector2i(2, 3)]).is_false()
	assert_that(Vector2i(3, 3) in dict).is_false()
	assert_that(Vector2i(2, 4) in dict).is_false()

## pieces ##################################################

func test_add_piece_and_piece_coords():
	var grid = BloxGrid.new({width=2, height=3})

	var crds = grid.piece_coords()
	assert_array(crds).is_empty()

	var p = BloxPiece.new({
		cells=[Vector2i()],
		coord=Vector2i(),
		})

	var ret = grid.add_piece(p)
	assert_bool(ret).is_true()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i()])

func test_can_add_piece():
	var grid = BloxGrid.new({width=2, height=3})

	var p = BloxPiece.new({
		cells=[Vector2i()],
		coord=Vector2i(),
		})

	var ret = grid.add_piece(p)
	assert_bool(ret).is_true()

	ret = grid.add_piece(p)
	assert_bool(ret).is_false()

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i()])


## tetris ##################################################

func test_can_piece_fall_tetris_style():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[Vector2i()], coord=Vector2i()})

	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i()])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(0, 1)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(0, 1)])


func test_can_piece_fall_tetris_style_tall():
	var grid = BloxGrid.new({width=2, height=3})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i.DOWN], coord=Vector2i()})

	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(), Vector2i(0, 1)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(0, 1), Vector2i(0, 2)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(0, 1), Vector2i(0, 2)])
