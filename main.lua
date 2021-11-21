dir = {
    up = 1,
    right = 2,
    down = 3,
    left = 4,
}

snake = {
    dir = dir.up,
    pos = {
        x = 64,
        y = 64,
    },
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

function update_direction(input, snake)
    if input.btn_left and input.btn_left_change then
        snake.dir = dir.left
    elseif input.btn_right and input.btn_right_change then
        snake.dir = dir.right
    elseif input.btn_up and input.btn_up_change then
        snake.dir = dir.up
    elseif input.btn_down and input.btn_down_change then
        snake.dir = dir.down
    end
end

function _update()
    input = poll_input(input)
    update_direction(input, snake)

    if snake.dir == dir.up then
        snake.pos.y -= 1
    elseif snake.dir == dir.down then
        snake.pos.y += 1
    elseif snake.dir == dir.left then
        snake.pos.x -= 1
    elseif snake.dir == dir.right then
        snake.pos.x += 1
    end
end

function _draw()
    cls(5)
    circfill(snake.pos.x, snake.pos.y, 7, 14)
end
