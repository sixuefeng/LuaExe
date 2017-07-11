
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "res/MainScene.csb"

function MainScene:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    self:setBGSize()

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function MainScene:setBGSize()
    local bg = self.resourceNode_:getChildByName("ProjectNode_1"):getChildByName("Image_1")
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local ratio = size.width / CC_DESIGN_RESOLUTION.width
    bg:setPosition(display.cx, display.cy)
    bg:setScale(ratio)
end




function MainScene:onCreate()

    local function onClickButton()
        myApp:run("MyScene")
        -- local scene = display.newScene(self.name_)
        
        -- local node = require("src/app/views/MyScene"):create()
        -- scene:addChild(node)
        -- display.runScene(scene)
    end
    local button = self.resourceNode_:getChildByName("ProjectNode_1"):getChildByName("Image_1"):getChildByName("Button")
    if button then 
        button:addTouchEventListener(onClickButton)
    end
    -- -- add background image
    -- display.newSprite("HelloWorld.png")
    --     :move(display.center)
    --     :addTo(self)

    -- -- add HelloWorld label
    -- cc.Label:createWithSystemFont("Hello World", "Arial", 40)
    --     :move(display.cx, display.cy + 200)
    --     :addTo(self)

    -- local sprite = cc.Sprite:create("HelloWorld.png")
    -- local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    -- sprite:setPosition(size.width / 2, size.height / 2)
    -- local ratio = size.width / CC_DESIGN_RESOLUTION.width
    -- sprite:setScale(ratio)
    -- self:addChild(sprite)
end

return MainScene
