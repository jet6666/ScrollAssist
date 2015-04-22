# ScrollAssist
是否受够了quick自带的uilistview不好用，现在使用这个很方便的使用

###滚动条辅助工具###
滚动条辅助工具
@特点：1.滚动区域的内容动态加载内容，不在范围内不操作，只有滚动到才操作 
       2.自动滚动到某一条内容去 
       3.只能设计竖向滚动!,且单元格的内容一样，等宽等高 
@方法： 
1.显示　　 
    self._list = ScrollAssist.new(_List , 单元格宽100,单元格高100,handler(self,self.onRender_) 单元格加载方法,handler(self, self.onRewardScrollEnd_)滚动回调
     function M:onRender_(  rowId , item ,isNew)
      if  isNew == true  then 
        return    TacticsRowItem.new()
      else 
      end
      item:update(rowId )
      end
    function M:onRewardScrollEnd_( event  )
      if event.name =="began" then 
         elseif event.name=="ended" then
      end
      return true 
    end
2.显示　
    self._list:fill(总条数,滚动到的条数)
3.取显示的更新: 
    self._list:getItemList() 
     for k,v in pairs(self._list:getItemList()) do v:update(XXXX)  end 
