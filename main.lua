function love.load()
    anim8 = require 'lib/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Initial game state here
    gameCanvas = love.graphics.newCanvas(256, 256)
    local scale = 2
    love.window.setMode(256 * scale, 256 * scale, {resizable=false, vsync=false})
    gameScale = scale
    player = {}
    player.x = 128
    player.y = 128
    player.speed = 64
    player.spritesheet = love.graphics.newImage("assets/sprite/placeholder.png")
    player.grid = anim8.newGrid(16, 16, player.spritesheet:getWidth(), player.spritesheet:getHeight())
    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid(1, '1-3'), 0.2)
    player.animations.right = anim8.newAnimation(player.grid(2, '1-3'), 0.2)
    player.animations.up = anim8.newAnimation(player.grid(3, '1-3'), 0.2)
    player.animations.left = anim8.newAnimation(player.grid(2, '1-3'), 0.2):flipH()
    player.anim = player.animations.down
end

function love.update(dt)
    local isMoving = false
    local isRunning = 1
    -- Update game state here
    if love.keyboard.isDown("x") then
        player.speed = 96
        isRunning = 2
    else
        player.speed = 64
        isRunning = 1
    end
    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
        player.anim = player.animations.up
        isMoving = true
    elseif love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
        player.anim = player.animations.down
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
        player.anim = player.animations.left
        isMoving = true
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        player.anim = player.animations.right
        isMoving = true
    end
    if isMoving then
        player.anim:update(dt * isRunning)
    else
        player.anim:gotoFrame(1)
    end
end

function love.draw()
    -- Draw everything to our canvas first
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    
    -- Draw your game content here
    player.anim:draw(player.spritesheet, player.x, player.y, nil, 2, 2, 8, 8)
    
    -- Draw your game HUD here
    
    -- Reset canvas and draw the scaled canvas to the screen
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0, 0, gameScale, gameScale)
end

function love.resize(w, h)
    local scale = math.min(w / 256, h / 256)
    gameScale = scale
end