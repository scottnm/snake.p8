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

function _update()
    if snake.dir == dir.up then
        snake.pos.y -= 1
    end
end

function _draw()
    cls(5)
    circfill(snake.pos.x, snake.pos.y, 7, 14)
end
