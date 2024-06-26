extends GdUnitTestSuite

func before():
	Log.set_colors_termsafe()

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
	assert_that(Vector2i(3, 4) in dict).is_false()
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


## tetris fall ##################################################

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
	var grid = BloxGrid.new({width=2, height=4})
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
	assert_array(crds).contains([Vector2i(0, 2), Vector2i(0, 3)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(0, 2), Vector2i(0, 3)])

## tetris row clear ##################################################

func test_tetris_clear_rows():
	var grid = BloxGrid.new({width=2, height=2})
	grid.add_piece(BloxPiece.new({cells=[Vector2i()], coord=Vector2i()}))
	grid.add_piece(BloxPiece.new({cells=[Vector2i(), Vector2i(0, -1)], coord=Vector2i(1, 0)}))

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([Vector2i(), Vector2i(1, 0), Vector2i(1, -1)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0)])

	var rows = grid.clear_rows()
	assert_int(len(rows)).is_equal(1)
	assert_int(len(rows[0])).is_equal(2)
	# TODO test row cells returned - cells are local to piece, have no root_coord! blast!

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(1, 0)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(1, 1)])

## piece rotation ##################################################

func test_rotate_piece():
	var grid = BloxGrid.new({width=3, height=3})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i(1, 0)],
		coord=Vector2i(1, 1)})
	grid.add_piece(p)

	var initial = [Vector2i(1, 1), Vector2i(2, 1)]
	var rotated_right = [Vector2i(1, 1), Vector2i(1, 2)]
	var rotated_left = [Vector2i(1, 1), Vector2i(1, 2)]

	var crds = grid.piece_coords()
	assert_array(crds).contains(initial)

	# rotate once right (clockwise)
	grid.rotate_piece(p, Vector2i.RIGHT)
	assert_array(p.grid_coords()).contains(rotated_right)
	crds = grid.piece_coords()
	assert_array(crds).contains(rotated_right)

	# rotate back
	grid.rotate_piece(p, Vector2i.LEFT)
	assert_array(p.grid_coords()).contains(initial)
	crds = grid.piece_coords()
	assert_array(crds).contains(initial)

	# rotate once left (counter-clockwise)
	grid.rotate_piece(p, Vector2i.LEFT)
	assert_array(p.grid_coords()).contains(rotated_left)
	crds = grid.piece_coords()
	assert_array(crds).contains(rotated_left)

func test_rotate_piece_bump():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i(0, 1)]})
	grid.add_piece(p)

	var initial = [Vector2i(), Vector2i(0, 1)]
	var rotated_bump = [Vector2i(), Vector2i(1, 0)]

	var crds = grid.piece_coords()
	assert_array(crds).contains(initial)

	# rotate clockwise, should bump to right
	grid.rotate_piece(p, Vector2i.RIGHT)
	assert_array(p.grid_coords()).contains(rotated_bump)
	crds = grid.piece_coords()
	assert_array(crds).contains(rotated_bump)

func test_rotate_piece_maintains_objects():
	var grid = BloxGrid.new({width=3, height=3})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i(1, 0)],
		coord=Vector2i(1, 1)})
	grid.add_piece(p)

	var cell_instance_ids = p.get_grid_cells().map(func(c):
		return c.get_instance_id())

	grid.rotate_piece(p, Vector2i.RIGHT)

	var updated_ids = p.get_grid_cells().map(func(c):
		return c.get_instance_id())

	assert_array(cell_instance_ids).is_equal(updated_ids)

## puyo split/fall ##################################################

func test_puyo_split():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
		]})
	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
		])

	grid.apply_split_puyo()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
	])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([
		Vector2i(),
		Vector2i(0, 1), Vector2i(1, 1),
	])

func test_puyo_split_splits_all_cells():
	var grid = BloxGrid.new({width=2, height=3})
	var p1 = BloxPiece.new({cells=[
		Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(0, 2),
		]})
	var p2 = BloxPiece.new({cells=[
		Vector2i(), Vector2i(1, 0),
		]})
	grid.add_piece(p1)
	grid.add_piece(p2)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(5)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(0, 2),
		])

	grid.apply_split_puyo()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(4)
	assert_int(len(crds)).is_equal(5)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(0, 2),
	])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(4)
	assert_int(len(crds)).is_equal(5)
	assert_array(crds).contains([
		Vector2i(),
		Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(0, 2), Vector2i(1, 2),
	])

func test_puyo_split_maintains_ids():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
		]})
	grid.add_piece(p)

	var cell_instance_ids = p.get_grid_cells().map(func(c):
		return c.get_instance_id())

	grid.apply_split_puyo()

	assert_int(len(grid.pieces)).is_equal(2)

	var p1_ids = grid.pieces[0].get_grid_cells().map(func(c):
		return c.get_instance_id())
	var p2_ids = grid.pieces[1].get_grid_cells().map(func(c):
		return c.get_instance_id())

	assert_int(len(p1_ids)).is_equal(2)
	assert_int(len(p2_ids)).is_equal(1)

	assert_array(cell_instance_ids).contains(p1_ids)
	assert_array(cell_instance_ids).contains(p2_ids)


## puyo group clear ##################################################

func test_puyo_group_clear_square():
	var grid = BloxGrid.new({
		width=2, height=2,
		})
	var p = BloxPiece.new({cells=[
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		],
		coord=Vector2i(),
		color=Color.RED,
		})
	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(4)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		])

	var ret = grid.clear_groups()

	# should remove 4 cells
	assert_array(ret.map(func(xs): return len(xs))).contains([4])

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(0)
	assert_int(len(crds)).is_equal(0)

func test_puyo_group_clear_t():
	var grid = BloxGrid.new({
		width=3, height=3,
		})
	var color = Color.RED
	grid.add_piece(
		BloxPiece.new({cells=[
			Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
							Vector2i(1, 1),
			# 				Vector2i(1, 0),
			# Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
			],
			coord=Vector2i(0, 0), color=color}))

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(4)
	# assert_array(crds).contains([
	# 						Vector2i(1, 0),
	# 		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
	# 	])

	# fall and settle
	grid.apply_step_tetris()
	grid.apply_split_puyo()
	grid.apply_step_tetris()
	grid.apply_step_tetris()

	var ret = grid.clear_groups()

	# should remove 4 cells
	assert_array(ret.map(func(xs): return len(xs))).contains([4])

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(0)
	assert_int(len(crds)).is_equal(0)

## step/tick ############################################

var step_opts = {
	puyo_split=true,
	puyo_group_clear=true,
	puyo_group_size=4,
	tetris_row_clear=true,
	}

func test_step_settles_board():
	var grid = BloxGrid.new({width=2, height=3})
	var p = BloxPiece.new({cells=[Vector2i()], coord=Vector2i(1, 0)})
	var ret = grid.add_piece(p)
	assert_bool(ret).is_true()

	while grid.step(step_opts): # run until false
		pass

	var crds = grid.piece_coords()
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(1, 2)])

func test_tick_clears_piece_t():
	var grid = BloxGrid.new({width=4, height=5})
	var ret = grid.add_piece(
		BloxPiece.new({cells=[
			Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
							Vector2i(1, 1),
			],
			coord=Vector2i(1, 0), color=Color.RED,
		}))
	assert_bool(ret).is_true()

	while grid.step(step_opts):
		pass

	var crds = grid.piece_coords()
	assert_int(len(crds)).is_equal(0)
	assert_array(crds).is_empty()

func test_tick_clears_piece_s():
	var grid = BloxGrid.new({width=4, height=5})
	var ret = grid.add_piece(
		BloxPiece.new({cells=[
			Vector2i(0, 0),
			Vector2i(0, 1), Vector2i(1, 1),
							Vector2i(1, 2),
			],
			coord=Vector2i(0, 0), color=Color.RED,
		}))
	assert_bool(ret).is_true()

	while grid.step(step_opts):
		pass

	var crds = grid.piece_coords()
	assert_int(len(crds)).is_equal(0)
	assert_array(crds).is_empty()
