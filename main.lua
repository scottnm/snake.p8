pico8_screen_size = 128
pellets = {}
snake = {
    segments = {},
}
score = 0

-- FIXME: maybe I should get rid of these component helpers if they're just bloating the code. I only have so many tokens and characters :)
function set_pos_cmpt(e, xpos, ypos)
    e.pos = { x = xpos, y = ypos }
end

function set_size_cmpt(e, size)
    e.size = size
end

function set_rect_collider_cmpt(e, w, h)
    e.collider = { width = w, height = h }
end

function set_direction_cmpt(e, dir)
    e.dir = dir
end

function set_color_cmpt(e, color)
    e.color = color
end

function rect_collision(e1, e2)
    x_collision_start = e1.pos.x - e2.collider.width
    x_collision_end = e1.pos.x + e1.collider.width
    y_collision_start = e1.pos.y - e2.collider.height
    y_collision_end = e1.pos.y + e1.collider.height

    return e2.pos.x >= x_collision_start and 
           e2.pos.x <= x_collision_end and
           e2.pos.y >= y_collision_start and
           e2.pos.y <= y_collision_end
end

function collides(e1, e2)
    return rect_collision(e1, e2) or rect_collision(e2, e1)
end

dir = {
    up = 1,
    right = 2,
    down = 3,
    left = 4,
}

-- FIXME: replace with a better btn enum state { off, pressed, held, released }
function poll_input(input)
    if input == nil then
        input = {
            btn_left = false,
            btn_left_change = false,
            btn_right = false,
            btn_right_change = false,
            btn_up = false,
            btn_up_change = false,
            btn_down = false,
            btn_down_change = false,
            btn_o = false,
            btn_o_change = false,
            btn_x = false,
            btn_x_change = false,
        }
    end

    new_input = {
        btn_left = btn(0),
        btn_right = btn(1),
        btn_up = btn(2),
        btn_down = btn(3),
        btn_o = btn(4),
        btn_x = btn(5),
    }

    input.btn_left_change = (input.btn_left ~= new_input.btn_left)
    input.btn_left = new_input.btn_left
    input.btn_right_change = (input.btn_right ~= new_input.btn_right)
    input.btn_right = new_input.btn_right
    input.btn_up_change = (input.btn_up ~= new_input.btn_up)
    input.btn_up = new_input.btn_up
    input.btn_down_change = (input.btn_down ~= new_input.btn_down)
    input.btn_down = new_input.btn_down
    input.btn_o_change = (input.btn_o ~= new_input.btn_o)
    input.btn_o = new_input.btn_o
    input.btn_x_change = (input.btn_x ~= new_input.btn_x)
    input.btn_x = new_input.btn_x

    return input
end

function generate_snake_segment(snake, xpos, ypos, dir)
    segment = {}

    set_pos_cmpt(segment, xpos, ypos)
    set_size_cmpt(segment, 4)
    set_rect_collider_cmpt(segment, 4, 4)
    set_color_cmpt(segment, 3)
    set_direction_cmpt(segment, dir)

    segment.last = {}
    set_pos_cmpt(segment.last, xpos, ypos)

    add(snake.segments, segment)
end

function generate_pellet(pellets)
    pellet = {}
    pellet_size = 4

    pellet_x = flr(rnd_int_range(0, pico8_screen_size) / pellet_size) * pellet_size
    pellet_y = flr(rnd_int_range(0, pico8_screen_size) / pellet_size) * pellet_size

    set_pos_cmpt(pellet, pellet_x, pellet_y)
    set_size_cmpt(pellet, pellet_size)
    set_rect_collider_cmpt(pellet, pellet_size, pellet_size)
    set_color_cmpt(pellet, 7)

    add(pellets, pellet)
end

function _init()
    generate_snake_segment(snake, 64, 64, dir.up)
    generate_pellet(pellets)
end

function rnd_int_range(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

function update_direction(input, snake)
    head = snake.segments[1]
    if input.btn_left and input.btn_left_change then
        head.dir = dir.left
    elseif input.btn_right and input.btn_right_change then
        head.dir = dir.right
    elseif input.btn_up and input.btn_up_change then
        head.dir = dir.up
    elseif input.btn_down and input.btn_down_change then
        head.dir = dir.down
    end
end

move_cnt = 0
function _update()
    -- get the next frame of input
    input = poll_input(input)

    -- potentially redirect the snake
    update_direction(input, snake)

    -- move all of the snake pieces
    move_cnt += 1
    if move_cnt == 15 then
        -- move the snake head and record its last position
        snake_head = snake.segments[1]
        snake_head.last.pos.x = snake_head.pos.x
        snake_head.last.pos.y = snake_head.pos.y

        if snake_head.dir == dir.up then
            snake_head.pos.y -= snake_head.size
        elseif snake_head.dir == dir.down then
            snake_head.pos.y += snake_head.size
        elseif snake_head.dir == dir.left then
            snake_head.pos.x -= snake_head.size
        elseif snake_head.dir == dir.right then
            snake_head.pos.x += snake_head.size
        end

        for i=2,#snake.segments do
            prev_segment = snake.segments[i - 1]
            segment = snake.segments[i]
            segment.last.pos.x = segment.pos.x
            segment.last.pos.y = segment.pos.y
            segment.pos.x = prev_segment.last.pos.x
            segment.pos.y = prev_segment.last.pos.y
        end

        move_cnt = 0
    end

    -- check for collisions with any pellets
    any_pellets_eaten = false
    for pellet in all(pellets) do
        if collides(snake.segments[1], pellet) then
            score += 1
            pellet.eaten = true
            any_pellets_eaten = true
            last_segment = snake.segments[#snake.segments]
            generate_snake_segment(snake, last_segment.last.pos.x, last_segment.last.pos.y, dir.up) -- fixme: dir.up not needed
        end
    end

    if any_pellets_eaten then
        -- clean up any eaten pellets
        next_pellet_idx = 1
        while next_pellet_idx <= #pellets do
            if pellets[next_pellet_idx].eaten then
                pellets[next_pellet_idx] = pellets[#pellets]
                pellets[#pellets] = nil
            else
                next_pellet_idx += 1
            end
        end
    end

    -- generate a new pellet if ready
    if any_pellets_eaten then
        generate_pellet(pellets)
    end

end

function draw_sqr(sqr)
    rect(sqr.pos.x, sqr.pos.y, sqr.pos.x + sqr.size, sqr.pos.y + sqr.size, sqr.color)
end

function printsqr(sqrname, pos, size, printx, printy)
    print(""..sqrname.." tl: (" ..pos.x.. ", " ..pos.y.. ") br: (" ..(pos.x+size).. ", " ..(pos.y+size).. ")", printx, printy, 7)
end

function _draw()
    cls(4)

    foreach(snake.segments, draw_sqr)
    foreach(pellets, draw_sqr)
    print("score: "..score, 0, 0, 7)

    -- printsqr("sk", snake.segments[1].pos, snake.segments[1].size, 0, 10)
    -- printsqr("p", pellets[1].pos, pellets[1].size, 0, 20)
end
