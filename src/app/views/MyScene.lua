
local MyScene = class("MyScene", cc.load("mvc").ViewBase)

MyScene.RESOURCE_FILENAME = "res/Scene.csb"

function MyScene:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name
    self.leftCount = 0
    self.rightCount = 0
    self.speed = 0
    self.speedAdd = 1
    self.speedDelete = 0.05
    self.updateCount = 0
    self.updateCountEve = 4
    self.speedMin = 0
    self.speedMax = 100
    self.action = false
    self.clicked = false
    self.xChange = true
    self.yChange = true
    self.ySpeed = 3

    self.ground = {}
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

    local function update(dt)
        if self.action then 
            self.leftCount = 0
            self.rightCount = 0
        end

        local ground
        local playerBox = self.player:getBoundingBox()
        for i, v in pairs(self.ground) do
            local groundBox = v:getBoundingBox()
            if cc.rectIntersectsRect(playerBox, groundBox) then
                ground = v
                break
            end
        end

        if ground then 
            print(1)
            local pointPlayerY = self.player:getPositionY()
            local pointGroundY = ground:getPositionY()
            if pointPlayerY >= pointGroundY then
            print(2)
                self.yChange = false
                self.xChange = true
            else
            print(3)
                self.yChange = true
                self.xChange = false
            end
        else
        print(4)
            self.yChange = true
            self.xChange = true
        end
     
        if self.yChange and not self.action then
        print(5)
            self.player:setPositionY(self.player:getPositionY() - self.ySpeed)
        end
        dump(self.yChange)
        dump(self.action)

        self.updateCount = self.updateCount + 1
        if self.updateCount % self.updateCountEve == 0 then
            self.updateCount = 0
            if self.speed > self.speedMin then
                self.speed = self.speed - self.speedDelete
            else
                self.speed = self.speedMin
            end
        end
        if self.xChange then
            if self.leftCount > 0 and self.rightCount > 0 then
                if self.speed < self.speedMax then
                    self.speed = self.speed + self.speedAdd
                else
                    self.speed = self.speedMax
                end
                self.leftCount = 0
                self.rightCount = 0
            elseif self.leftCount == 0 and self.rightCount > 1 then
                self.action = true
                local jump = cc.MoveBy:create(0.5, cc.p(0, 280))
                local jumpBy = jump:reverse()
                local function actionOver()
                    self.action = false
                end
                local func = cc.CallFunc:create(actionOver)
                local seq = cc.Sequence:create(jump, func)--, jumpBy

                self.player:runAction(seq)

                self.leftCount = 0
                self.rightCount = 0
            elseif self.leftCount > 1 and self.rightCount == 0 then
                self.action = true
                local scale = cc.ScaleTo:create(0.5, 0.5)
                local scaleBy = cc.ScaleTo:create(0.5, 1)
                local function actionOver()
                    self.action = false
                end
                local func = cc.CallFunc:create(actionOver)
                local seq = cc.Sequence:create(scale, scaleBy, func)

                self.player:runAction(seq)

                self.leftCount = 0
                self.rightCount = 0
            else
            
            end 
        end
        self.bg1:setPositionX(self.bg1:getPositionX() - self.speed)
        self.bg2:setPositionX(self.bg2:getPositionX() - self.speed)

        for i, v in pairs(self.ground) do
            v:setPositionX(v:getPositionX() - self.speed)
        end

        if self.bg1:getPositionX() <= -display.cx then
            self.bg1:setPositionX(self.bg1:getPositionX() + display.cx * 4)
        end
        
        if self.bg2:getPositionX() <= -display.cx then
            self.bg2:setPositionX(self.bg2:getPositionX() + display.cx * 4)
        end
        self.clicked = false
    end
    self:scheduleUpdateWithPriorityLua(update,0)

    
    local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(false)
    listener:registerScriptHandler(handler(self, MyScene.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(handler(self, Layer.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, MyScene.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function MyScene:setBGSize()
    self.bg1 = self.resourceNode_:getChildByName("Image_1")
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local ratio = size.width / CC_DESIGN_RESOLUTION.width
    self.bg1:setPosition(display.cx, display.cy)
    self.bg1:setScale(ratio)

    
    self.bg2 = self.resourceNode_:getChildByName("Image_2")
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local ratio = size.width / CC_DESIGN_RESOLUTION.width
    self.bg2:setPosition(display.cx * 3, display.cy)
    self.bg2:setScale(ratio)
end

function MyScene:onCreate()

    self.player = self.resourceNode_:getChildByName("Image_Player")
    for i = 1, 9 do
        local ground = self.resourceNode_:getChildByName("Image_Ground"..i)
        table.insert(self.ground,ground)
    end

    -- local children2 = self.bg2:getChildren()
    -- for i, v in pairs(children2) do
    --     table.insert(self.ground,v)
    -- end
    -- dump(self.ground)
end


function MyScene:onTouchBegan(touch, event)
    if self.clicked then return false end

    self.clicked = true
    return true
end

function MyScene:onTouchEnded(touch, event)
    local point = touch:getLocation()
    if point.x > display.cx then
        self.rightCount = self.rightCount + 1
    else
        self.leftCount = self.leftCount + 1
    end
end

return MyScene

-- var hBox=this.hero.getBoundingBox();//主角碰撞框
-- var eBox=this.enemy.getBoundingBox();//敌人碰撞框
-- 其次如何判断他们发生了碰撞：
-- if(cc.rectIntersectsRect(hBox, eBox)){//判断主角与敌人是否发生碰撞