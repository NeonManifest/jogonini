function love.load()
    anim8 = require 'lib/anim8'
    DialogueManager = require 'dialogue'
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Configure sound
    sound = love.audio.newSource("assets/sound/coin10.wav", "static")
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
    player.interact = {player.x-2, player.y + 16}
    -- Town NPCS
    townNPCs = {}
    townNPCs[1] = {}
    townNPCs[1].spritesheet = love.graphics.newImage("assets/sprite/placeholder.png")
    townNPCs[1].grid = anim8.newGrid(16, 16, townNPCs[1].spritesheet:getWidth(), townNPCs[1].spritesheet:getHeight())
    townNPCs[1].animations = {}
    townNPCs[1].animations.down = anim8.newAnimation(townNPCs[1].grid(4, '1-3'), 0.2)
    townNPCs[1].animations.right = anim8.newAnimation(townNPCs[1].grid(5, '1-3'), 0.2)
    townNPCs[1].animations.up= anim8.newAnimation(townNPCs[1].grid(6, '1-3'), 0.2)
    townNPCs[1].animations.left = anim8.newAnimation(townNPCs[1].grid(5, '1-3'), 0.2):flipH()
    townNPCs[1].anim = townNPCs[1].animations.down
    townNPCs[1].x = 96
    townNPCs[1].y = 96
    townNPCs[1].dialogue = {"Good evening! Bask in the pale moonlight! Remember the times long gone when things were brighter. Remember your sweetest dreams.", "Welcome to the game!"}
    -- Set update loop to explore state
    love.update = updateExplore
    dialogueManager = DialogueManager:new()
end

function love.draw()
    -- Draw everything to our canvas first
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    
    -- Draw your game content here
    local drawables = {}
    table.insert(drawables, player)
    for _, npc in ipairs(townNPCs) do
        table.insert(drawables, npc)
    end
    
    table.sort(drawables, function(a, b) return a.y < b.y end)
    
    for _, entity in ipairs(drawables) do
        entity.anim:draw(entity.spritesheet, entity.x, entity.y, nil, 2, 2, 8, 8)
    end
    -- Draw your game HUD here
    
    -- Draw dialogue if active
    local currentDialogue = dialogueManager:getCurrentDialogue()
    if currentDialogue then
        -- Dialogue box size
        local boxX, boxY = 4, 4
        local boxW, boxH = 248, 68
        -- Player sprite size
        local playerW, playerH = 32, 32
        -- Default: show at bottom
        boxY = 256 - boxH - 4
        -- Check if box would cover player
        local playerBottom = player.y + playerH / 2
        if playerBottom + 4 > boxY then
            -- Show at top if covered
            boxY = 4
        end
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", boxX, boxY, boxW, boxH)
        love.graphics.setColor(1, 1, 1)
        local substring = string.sub(currentDialogue, 1, dialogueManager.currentSubstringIndex)
        -- Simple word wrap
        local function wrap(text, maxW)
            local t, l = {}, ""
            for w in text:gmatch("%S+") do
            local test = l == "" and w or (l .. " " .. w)
            if love.graphics.getFont():getWidth(test) > maxW then
                table.insert(t, l)
                l = w
            else
                l = test
            end
            end
            if l ~= "" then table.insert(t, l) end
            return t
        end
        for i, l in ipairs(wrap(substring, boxW - 12)) do
            love.graphics.print(l, boxX + 6, boxY + 6 + (i - 1) * love.graphics.getFont():getHeight())
        end
    end

    -- Reset canvas and draw the scaled canvas to the screen
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0, 0, gameScale, gameScale)
end

function love.resize(w, h)
    local scale = math.min(w / 256, h / 256)
    gameScale = scale
end

function updateExplore(dt)
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
        player.interact = {player.x-2, player.y - 16}
        isMoving = true
    elseif love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
        player.anim = player.animations.down
        player.interact = {player.x-2, player.y + 16}
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
        player.anim = player.animations.left
        player.interact = {player.x - 16, player.y}
        isMoving = true
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        player.anim = player.animations.right
        player.interact = {player.x + 16, player.y}
        isMoving = true
    end
    if isMoving then
        player.anim:update(dt * isRunning)
    else
        player.anim:gotoFrame(1)
    end
end

function love.keypressed(key)
    if key == "z" then
        if love.update == updateDialogue then
            local currentText = dialogueManager.dialogues[dialogueManager.currentDialogueIndex]
            if dialogueManager.currentSubstringIndex < #currentText then
                dialogueManager.currentSubstringIndex = #currentText
            else
                dialogueManager:advance()
            end
        elseif love.update == updateExplore then
            for _, npc in ipairs(townNPCs) do
                if (distance(npc.x,npc.y,player.interact[1],player.interact[2]) <= 10) then
                    -- Turn the NPC to the right direction
                    local dx = player.x - npc.x
                    local dy = player.y - npc.y
                    if math.abs(dx) > math.abs(dy) then
                        if dx > 0 then
                            npc.anim = npc.animations.right
                        else
                            npc.anim = npc.animations.left
                        end
                    else
                        if dy > 0 then
                            npc.anim = npc.animations.down
                        else
                            npc.anim = npc.animations.up
                        end
                    end
                    -- Start the dialogue
                    dialogueManager = DialogueManager:new(npc.dialogue)
                    dialogueManager:start()
                    love.update = updateDialogue
                end
                break
            end
        end
    end
end

function updateDialogue(dt)
    if not dialogueManager.isActive then
        love.update = updateExplore
    else
        if love.keyboard.isDown("x") then
            local currentText = dialogueManager.dialogues[dialogueManager.currentDialogueIndex]
            if dialogueManager.currentSubstringIndex < #currentText then
                dialogueManager.currentSubstringIndex = #currentText
            end
        end
        -- Show next character every 0.15s
        dialogueManager._substringTimer = (dialogueManager._substringTimer or 0) + dt
        local currentText = dialogueManager.dialogues[dialogueManager.currentDialogueIndex]
        if dialogueManager.currentSubstringIndex <= #currentText then
            if dialogueManager._substringTimer >= 0.025 then
                dialogueManager.currentSubstringIndex = dialogueManager.currentSubstringIndex + 1
                dialogueManager._substringTimer = 0
                sound:play()
            end
        end
    end
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end