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

function set_circle_collider_cmpt(e, r)
    e.collider = { radius = r }
end

function set_direction_cmpt(e, dir)
    e.dir = dir
end

function set_color_cmpt(e, color)
    e.color = color
end

function collides(e1, e2)
    max_collision_radius = e1.collider.radius + e2.collider.radius
    max_collision_radius_squared = max_collision_radius * max_collision_radius

    x_delta = (e1.pos.x - e2.pos.x)
    y_delta = (e1.pos.y - e2.pos.y)
    distance_squared = (x_delta * x_delta) + (y_delta * y_delta)

    return distance_squared <= max_collision_radius_squared
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

    input.btn_left_change = (input.btn_left_change ~= new_input.btn_left)
    input.btn_left = new_input.btn_left
    input.btn_right_change = (input.btn_right_change ~= new_input.btn_right)
    input.btn_right = new_input.btn_right
    input.btn_up_change = (input.btn_up_change ~= new_input.btn_up)
    input.btn_up = new_input.btn_up
    input.btn_down_change = (input.btn_down_change ~= new_input.btn_down)
    input.btn_down = new_input.btn_down
    input.btn_o_change = (input.btn_o_change ~= new_input.btn_o)
    input.btn_o = new_input.btn_o
    input.btn_x_change = (input.btn_x_change ~= new_input.btn_x)
    input.btn_x = new_input.btn_x

    return input
end

function generate_snake_segment(snake, xpos, ypos, dir)
    segment = {}

    set_pos_cmpt(segment, xpos, ypos)
    set_size_cmpt(segment, 7)
    set_circle_collider_cmpt(segment, 7)
    set_color_cmpt(segment, 3)
    set_direction_cmpt(segment, dir)

    add(snake.segments, segment)
end

function generate_pellet(pellets)
    pellet = {}

    pellet_x = rnd_range(0, pico8_screen_size)
    pellet_y = rnd_range(0, pico8_screen_size)
    set_pos_cmpt(pellet, pellet_x, pellet_y)

    set_size_cmpt(pellet, 2)
    set_circle_collider_cmpt(pellet, 2)
    set_color_cmpt(pellet, 7)

    add(pellets, pellet)
end

function _init()
    generate_snake_segment(snake, 64, 64, dir.up)
    generate_pellet(pellets)
end

function rnd_range(lower, upper)
    return rnd(upper - lower) + lower
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

function _update()
    -- get the next frame of input
    input = poll_input(input)

    -- potentially redirect the snake
    update_direction(input, snake)

    -- move all of the snake pieces
    for segment in all(snake.segments) do
        if segment.dir == dir.up then
            segment.pos.y -= 1
        elseif segment.dir == dir.down then
            segment.pos.y += 1
        elseif segment.dir == dir.left then
            segment.pos.x -= 1
        elseif segment.dir == dir.right then
            segment.pos.x += 1
        end
    end

    -- check for collisions with any pellets
    any_pellets_eaten = false
    for pellet in all(pellets) do
        if collides(snake.segments[1], pellet) then
            score += 1
            pellet.eaten = true
            any_pellets_eaten = true
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

function draw_snake_segment(segment)
    circfill(segment.pos.x, segment.pos.y, segment.size, segment.color)
end

function draw_pellet(pellet)
    circfill(pellet.pos.x, pellet.pos.y, pellet.size, pellet.color)
end

function _draw()
    cls(4)

    foreach(snake.segments, draw_snake_segment)
    foreach(pellets, draw_pellet)
    print("score: "..score, 0, 0, 7)
end
