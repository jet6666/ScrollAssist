local M = class("ScrollViewPatch", cc.ui.UIScrollView)
--修正uiscrollview,滚动到最上去回不来的情况
--url : https://github.com/dualface/v3quick/pull/421/files
function M:elasticScroll()
  local cascadeBound = self:getScrollNodeRect()
  local disX, disY = 0, 0
  local viewRect =self:getViewRect() -- self:getViewRectInWorldSpace()
  local t = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))

  cascadeBound.x = t.x
  cascadeBound.y = t.y
  cascadeBound.width = cascadeBound.width / self.scaleToWorldSpace_.x
  cascadeBound.height = cascadeBound.height / self.scaleToWorldSpace_.y

  --
  if cascadeBound.width < viewRect.width then
    disX = viewRect.x - cascadeBound.x
  else
    if cascadeBound.x > viewRect.x then
      disX = viewRect.x - cascadeBound.x
    elseif cascadeBound.x + cascadeBound.width < viewRect.x + viewRect.width then
      disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
    end
  end

  if cascadeBound.height < viewRect.height then
    disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
  else
    if cascadeBound.y > viewRect.y then
      disY = viewRect.y - cascadeBound.y
    elseif cascadeBound.y + cascadeBound.height < viewRect.y + viewRect.height then
      disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
    end
  end

  if 0 == disX and 0 == disY then
    return
  end

  transition.moveBy(self.scrollNode,
    {x = disX, y = disY, time = 0.3,
      easing = "backout",
      onComplete = function()
        self:callListener_{name = "scrollEnd"}
      end})

end
return M
