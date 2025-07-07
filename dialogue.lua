local DialogueManager = {}

function DialogueManager:new(dialogues)
    local obj = {
        dialogues = dialogues or {},
        currentDialogueIndex = 1,
        isActive = false
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function DialogueManager:start()
    self.isActive = true
    self.currentDialogueIndex = 1
end

function DialogueManager:advance()
    if self.isActive then
        self.currentDialogueIndex = self.currentDialogueIndex + 1
        if self.currentDialogueIndex > #self.dialogues then
            self.isActive = false
        end
    end
end

function DialogueManager:getCurrentDialogue()
    if self.isActive then
        return self.dialogues[self.currentDialogueIndex]
    end
    return nil
end

-- Example code when talking to an NPC
--     local dialogues = {
--        "Welcome to the game!",
--        "Use arrow keys to move.",
--        "Press 'x' to run.",
--        "Good luck!"
--    }
--    dialogueManager = DialogueManager:new(dialogues)
--    dialogueManager:start()

return DialogueManager