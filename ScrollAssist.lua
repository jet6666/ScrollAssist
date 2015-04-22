--滚动条辅助工具，
--@特点：1.滚动区域的内容动态加载内容，不在范围内不操作，只有滚动到才操作
--       2.自动滚动到某一条内容去
--       3.只能设计竖向滚动!,且单元格的内容一样，等宽等高
--@方法：
--1.显示　　self._list = ScrollAssist.new(_List , 单元格宽100,单元格高100,handler(self,self.onRender_) 单元格加载方法,handler(self, self.onRewardScrollEnd_)滚动回调
-- function M:onRender_(  rowId , item ,isNew)
--  if  isNew == true  then 
--    return    TacticsRowItem.new()
--  else 
--  end
--  item:update(rowId )
--  end
--function M:onRewardScrollEnd_( event  )
--  if event.name =="began" then 
--     elseif event.name=="ended" then
--  end
--  return true 
--end
--2.显示　elf._list:fill(总条数,滚动到的条数)
--3.取显示的更新: self._list:getItemList() 
-- for k,v in pairs(self._list:getItemList()) do v:update(XXXX)  end 

local modelName = "ScrollAssist"
local M=class(modelName)

--常用函数
local SIZE = function(node) return node:getContentSize(); end
local W = function(node) return node:getContentSize().width; end
local H = function(node) return node:getContentSize().height; end
local S_SIZE = function(node,w,h) return node:setContentSize(CCSize(w,h)); end
local S_XY = function(node,x,y) node:setPosition(x,y); end
local AX = function(node) return node:getAnchorPoint().x; end
local AY = function(node) return node:getAnchorPoint().y; end
local G_X = function(node ) return node:getPositionX(); end
local G_Y = function(node ) return node:getPositionY(); end
--三元运算符
local CALC_3 = function(exp, result1, result2) if(exp==true)then return result1; else return result2; end 
end
local S_Y = function(node,y) node:setPositionY(y); end
local RANGE = function(value,min,max) return math.max(math.min(max,value),min) end

function M:ctor( view ,itemWidth,itemHeight ,onRender  ,onTouch)
  self._view =view 
  --创建一个容器node
  local innerContainer = display.newNode();
  --初始容器大小为视图大小
  S_SIZE(innerContainer,view:getViewRect().width,view:getViewRect().height);
  view:addScrollNode(innerContainer);
  view:onScroll(handler(self, self.scrollListener_))
  local listviewtype =tolua.type(view)
  local isClippingRegon = listviewtype == "CCClippingRegionNode" or listviewtype=="cc.ClippingRectangleNode"
  --初始位置
  local containerX,containerY
  if isClippingRegon == true then
    containerX  = view:getViewRect().x      containerY = view:getViewRect().y
  else
    containerX = G_X(container)   containerY = G_Y(container)
  end
  self._x = containerX self._y = containerY
  self._params = {itemSize= CCSize(itemWidth,itemHeight)}
  self._renderCallback = onRender
  self._nodes = {}
  self._onTouch = onTouch 
  self._lockList = {}
  self._lock = false 
end 

--设置间隙
function M:setGap( valueX,valueY  )
  self._params.heightGap = valueY 
  self._params.widthGap = valueX 
end
 

-- 列表,注意，这里只显示已经显示出来过的元素
function M:getItemList()
  return self._nodes
end

--不再提供直接滚动到某一条的方法，直接用fill(total , id )
function M:scrollToId(id )
end 

function M:scrollListener_( event )
  if event.name =="began" or event.name =="moved" or event.name =="ended" then 
    local h= self._params.itemSize.height + self._params.heightGap
    local H=H(self._view )
    local T = self._nums ;
    --显示范围
    local y  = math.abs(self._view:getScrollNode():getPositionY() -  self._y)
    local idMin = T - math.ceil( (y + H) /h)
    local idMax = T - math.floor(y/h)
    idMin = math.max(0,idMin) --print(">出现的是 > " , idMin ,"  <=",idMax )
    self:render_(idMin ,idMax ,true ) 
  end 
  if self._onTouch ~=nil and tolua.type(self._onTouch) == "function"  then   self._onTouch(event)  end
end

--当前显示出来的id范围
function M:getRange_(  id  ,total  )
  local h=  self._params.itemSize.height+ self._params.heightGap
  local H= H(self._view )
  local yScroll = H -(total -id+1 )* h
  if total*h <= H then yScroll = H- total*h 
  else    yScroll = RANGE(yScroll , H -(total+1 )* h , 0 )    
  end
  S_XY(self._view:getScrollNode(),  self._x  , yScroll +self._y)
  --显示范围
  local y  = math.abs(self._view:getScrollNode():getPositionY() - self._y)
  local idMin = total - math.ceil( (y + H) /h)
  local idMax = total - math.floor(y/h) --print(">出现的是 > " , idMin ,"  <=",idMax , ",y=",y ,",total",total,",yScroll=",yScroll,h,H)
  return math.max(0,idMin),idMax
end

--显示范围的表格
function M:render_( min ,max  ,ignoreOld)
  local innerContainer = self._view:getScrollNode() 
  local params = self._params
  for i = min+1 ,max  do
    local new =false 
    local n = self._nodes[i]
    if n == nil then 
      new = true 
      n  = self._renderCallback( i   ,item ,true  )
      self._nodes[i] = n
    end 
    if ignoreOld == true and new ==false then else  
      local x = 0.0;
      local y = 0.0;
      x = params.widthGap + math.floor((i-1) % params.cellCount) * (params.widthGap+params.itemSize.width);
      y = H(innerContainer)-(math.floor((i-1)/params.cellCount)+1)*(params.heightGap+params.itemSize.height);
      x = x + W(n) * AX(n);
      y = y + H(n) * AY(n);
      S_XY(n,x,y);
      self._renderCallback(i     ,n  ,false   )
      if new then    n:addTo(innerContainer) end 
    end 

  end
end

--老的元素修改位置 
function M:renderOld_( min ,max  ,ignoreOld)
  local innerContainer = self._view:getScrollNode() 
  local params = self._params
  local oldList ={}
  for i=1,min,1 do 
    if self._nodes[i] ~= nil then  table.insert(oldList,i) end  
  end 
  for i=max,self._nums ,1 do 
    if self._nodes[i] ~= nil then  table.insert(oldList,i) end 
  end 
  for _,i in pairs(oldList) do 
    local n= self._nodes[i]
    local x = 0.0;
    local y = 0.0;
    x = params.widthGap + math.floor((i-1) % params.cellCount) * (params.widthGap+params.itemSize.width);
    y = H(innerContainer)-(math.floor((i-1)/params.cellCount)+1)*(params.heightGap+params.itemSize.height);
    x = x + W(n) * AX(n);
    y = y + H(n) * AY(n);
    S_XY(n,x,y);
    self._renderCallback(i     ,n  ,false   )
  end 
end

--填充元素
function M:fill(nodes,id)
  --多参数的继承用法,把param2的参数增加覆盖到param1中。
  local view =self._view 
  local extend = function(param1,param2)
    if not param2 then
      return param1;
    end
    for k , v in pairs(param2) do
      param1[k] = param2[k];
    end
    return param1;
  end

  local params = extend({
      --自动间距
      autoGap = false,
      --宽间距
      widthGap = 0,
      --高间距
      heightGap = 0,
      --自动行列
      autoTable = true,
      --行数目
      rowCount = 3,
      --列数目
      cellCount = 10,
      --填充项大小
      itemSize = CCSize(50,50)
      },self._params);
  self._params = params
  if nodes == 0 then
    return nil;
  end 
  --删除多余的
  local item 
  if self._nums ~=nil then 
    for i = nodes+1 ,self._nums ,1 do
      item = self._nodes[i]
      if item~=nil then item:removeFromParent()  self._nodes[i] =nil end 
    end 
  end 
  self._nums = nodes 
  -- 一个容器node
  local innerContainer = self._view:getScrollNode();
  --初始容器大小为视图大小
  S_SIZE(innerContainer,view:getViewRect().width,view:getViewRect().height);
  --滚动到的范围
  if id == nil then id = 1 end 
  id =math.max(id,math.min(nodes,id) ,1)
  local min,max = self:getRange_(id , nodes)
  --先调整一下原先存在的位置  显示的是> min <=max


  --如果是纵向布局
  if view.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then

    --自动布局
    if params.autoTable then
      params.cellCount = math.floor(W(view)/params.itemSize.width);
    end

    --自动间隔,设置成０，不然就会出现宽的出来奇怪的排版
    if params.autoGap then
      params.widthGap = 0--(W(view)-(params.cellCount*params.itemSize.width))/(params.cellCount+1);
      params.heightGap = 0--params.widthGap;
    end

    --填充量
    params.rowCount = CALC_3(nodes%params.cellCount==0,math.floor(nodes/params.cellCount),math.floor(nodes/params.cellCount)+1);
    S_SIZE(innerContainer,W(view),(params.itemSize.height+params.heightGap)*params.rowCount+params.heightGap);
    self:render_(min,max,false )
    self:renderOld_(min,max,false )
  else
    if(params.autoTable)then
      params.rowCount = math.floor(H(view)/params.itemSize.height);
    end

    if(params.autoGap)then
      params.heightGap = (H(view)-(params.rowCount*params.itemSize.height))/(params.rowCount+1);
      params.widthGap = params.heightGap;
    end

    params.cellCount = CALC_3(nodes%params.rowCount==0,math.floor(nodes/params.rowCount),math.floor(nodes/params.rowCount)+1);
--      print(params.cellCount)
    S_SIZE(innerContainer,(params.itemSize.width+params.widthGap)*params.cellCount+params.widthGap,H(view));
--      print( (params.itemSize.width+params.widthGap)*params.cellCount+params.widthGap)

    for i = 1, #(nodes) do

      local n = nodes[i];
      local x = 0.0;
      local y = 0.0;

      --不管描点如何，总是有标准居中方式设置坐标。
      x = params.widthGap +  math.floor((i-1) / params.rowCount) * (params.widthGap+params.itemSize.width);
      y = H(innerContainer)-(math.floor((i-1) % params.rowCount) +1)*(params.heightGap+params.itemSize.height);
      x = x + W(n) * AX(n);
      y = y + H(n) * AY(n);

      S_XY(n,x,y);
--        print(">>>>" , i , x , y )
      n:addTo(innerContainer);

    end

  end

end


return M 